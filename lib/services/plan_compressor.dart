import '../models/task_item.dart';
import '../models/compressed_task.dart';

// 압축 결과를 화면에 한 번에 전달하기 위한 묶음 객체.
class CompressionResult {
  final List<CompressedTask> tasks;
  final String successCriteria;
  final List<String> timeBlocks;

  CompressionResult({
    required this.tasks,
    required this.successCriteria,
    required this.timeBlocks,
  });
}

// 규칙 기반 압축기.
// 향후 OpenAI API 등으로 교체할 수 있도록 이 클래스만 갈아끼우면 되도록 분리한다.
class PlanCompressor {
  CompressionResult compress({
    required List<TaskItem> tasks,
    required String fixedSchedule,
    required String freeTime,
    required int condition, // 0~100
    required String mustDo, // 오늘 꼭 살릴 일 이름 (콤마 가능)
  }) {
    // 1) 꼭 살릴 일 이름 분리
    final mustDoNames = mustDo
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // 2) 각 task에 우선순위 점수 부여
    final scored = <_ScoredTask>[];
    for (final t in tasks) {
      double score = 0;
      if (mustDoNames.contains(t.name)) score += 100;
      // 마감
      if (t.deadline == Deadline.today) {
        score += 30;
      } else if (t.deadline == Deadline.tomorrow) {
        score += 15;
      } else if (t.deadline == Deadline.thisWeek) {
        score += 5;
      }
      // 손실
      if (t.loss == Loss.large) {
        score += 25;
      } else if (t.loss == Loss.medium) {
        score += 10;
      }
      // 컨디션이 낮을수록 부담 큰 항목 감점
      final lowEnergy = condition < 50;
      if (lowEnergy && _isOptional(t.name)) score -= 20;
      scored.add(_ScoredTask(task: t, score: score));
    }

    // 3) 점수 내림차순 정렬
    scored.sort((a, b) => b.score.compareTo(a.score));

    // 4) 처리 타입 결정 + 시간 압축
    final compressed = <CompressedTask>[];
    int priority = 1;

    for (final s in scored) {
      final t = s.task;
      ProcessType pType;
      int duration;

      final isMust = mustDoNames.contains(t.name);
      final urgent = t.deadline == Deadline.today && t.loss == Loss.large;

      if (isMust || urgent) {
        pType = ProcessType.core;
        duration = _capDuration(t.estimatedMinutes, max: 60);
      } else if (s.score >= 20) {
        pType = ProcessType.keep;
        duration = _capDuration(t.estimatedMinutes, max: 30);
      } else if (s.score >= 0) {
        pType = ProcessType.minimum;
        duration = 15;
      } else {
        pType = ProcessType.exclude;
        duration = 0;
      }

      // 컨디션이 낮으면 비중요 항목 강등.
      // (점수가 아니라 컨디션 때문에 줄였다는 사실을 문구에 반영하기 위해 표시)
      var conditionAdjusted = false;
      if (condition < 40 && !isMust && !urgent && _isOptional(t.name)) {
        pType = ProcessType.minimum;
        duration = 15;
        conditionAdjusted = true;
      }
      if (condition < 25 && !isMust && !urgent) {
        pType = ProcessType.exclude;
        duration = 0;
        conditionAdjusted = true;
      }

      compressed.add(CompressedTask(
        priority: pType == ProcessType.exclude ? -1 : priority,
        name: t.name,
        time: pType == ProcessType.exclude ? '-' : '$duration분',
        processType: pType,
        durationMinutes: duration,
        reason: _reasonFor(
          type: pType,
          isMust: isMust,
          urgent: urgent,
          conditionAdjusted: conditionAdjusted,
        ),
      ));

      if (pType != ProcessType.exclude) priority++;
    }

    // 5) 고정 일정을 가장 위에 "반드시"로 추가
    if (fixedSchedule.trim().isNotEmpty) {
      compressed.insert(
        0,
        CompressedTask(
          priority: 1,
          name: fixedSchedule.trim(),
          time: '고정',
          processType: ProcessType.mandatory,
          reason: _reasonFor(
            type: ProcessType.mandatory,
            isMust: true,
            urgent: false,
            conditionAdjusted: false,
          ),
        ),
      );
      // 뒤의 우선순위 다시 매기기 (제외는 그대로)
      var p = 1;
      final relabeled = <CompressedTask>[];
      for (final c in compressed) {
        if (c.processType == ProcessType.exclude) {
          relabeled.add(c);
        } else {
          relabeled.add(CompressedTask(
            priority: p,
            name: c.name,
            time: c.time,
            processType: c.processType,
            durationMinutes: c.durationMinutes,
            reason: c.reason,
          ));
          p++;
        }
      }
      compressed
        ..clear()
        ..addAll(relabeled);
    }

    // 6) 성공 기준 (반드시 + 핵심 항목 이름 묶기)
    final criticalNames = compressed
        .where((c) =>
            c.processType == ProcessType.mandatory ||
            c.processType == ProcessType.core)
        .map((c) => c.name)
        .toList();
    final successCriteria = criticalNames.isEmpty
        ? '오늘은 무리하지 않고 컨디션 회복이 목표'
        : '${criticalNames.join(' + ')} 완료하면 성공';

    // 7) 시간 배치
    final timeBlocks = _buildTimeBlocks(
      compressed: compressed,
      fixedSchedule: fixedSchedule,
      freeTime: freeTime,
    );

    return CompressionResult(
      tasks: compressed,
      successCriteria: successCriteria,
      timeBlocks: timeBlocks,
    );
  }

  // 처리 유형과 맥락(꼭 살릴 일/긴급/컨디션 조정 여부)에 맞춰
  // "왜 이렇게 배치했는지"를 사용자 친화적인 문장으로 만든다.
  String _reasonFor({
    required ProcessType type,
    required bool isMust,
    required bool urgent,
    required bool conditionAdjusted,
  }) {
    switch (type) {
      case ProcessType.mandatory:
        return '이미 정해진 고정 일정이에요. 하루의 기준점이 되도록 가장 먼저 배치했어요.';
      case ProcessType.core:
        if (isMust) {
          return '오늘 반드시 살려야 하는 일로 직접 선택했기 때문에 먼저 배치했어요.';
        }
        return '오늘이 마감이고 미루면 손실이 커서, 가장 먼저 처리할 핵심으로 올렸어요.';
      case ProcessType.keep:
        return '남은 시간 안에서 충분히 해낼 수 있어, 오늘 안에 유지하기로 했어요.';
      case ProcessType.minimum:
        if (conditionAdjusted) {
          return '지금 컨디션을 고려해 부담을 덜었어요. 오늘은 최소한만 가볍게 손대도 충분해요.';
        }
        return '우선순위는 높지 않지만, 짧게라도 손대 두면 내일이 한결 가벼워져요.';
      case ProcessType.exclude:
        if (conditionAdjusted) {
          return '지금 컨디션이라면 무리하기 쉬워요. 오늘은 전략적으로 내려놓고 내일로 넘기는 편이 안전해요.';
        }
        return '남은 시간과 컨디션을 고려하면, 오늘은 제외하고 내일로 넘기는 편이 안전해요.';
    }
  }

  // 컨디션 떨어졌을 때 우선 줄이고 싶은 카테고리
  bool _isOptional(String name) {
    final lower = name.toLowerCase();
    return lower.contains('운동') ||
        lower.contains('영어') ||
        lower.contains('취미') ||
        lower.contains('독서');
  }

  int _capDuration(int minutes, {required int max}) {
    if (minutes >= 120) return max; // 2시간+ -> max로 강제 축소
    if (minutes > max) return max;
    return minutes;
  }

  List<String> _buildTimeBlocks({
    required List<CompressedTask> compressed,
    required String fixedSchedule,
    required String freeTime,
  }) {
    final blocks = <String>[];
    if (fixedSchedule.trim().isNotEmpty) {
      blocks.add(fixedSchedule.trim());
    }

    // freeTime 예: "19:00~23:30" → 19:00을 시작 시각으로 사용
    final start = _parseStart(freeTime) ?? const _Time(19, 0);
    var current = start;

    for (final t in compressed) {
      if (t.processType == ProcessType.mandatory) continue; // 위에서 이미 표기
      if (t.processType == ProcessType.exclude) continue;
      final dur = t.durationMinutes;
      if (dur <= 0) continue;
      final end = current.addMinutes(dur);
      blocks.add('${current.format()}~${end.format()} ${t.name}');
      // 항목 사이 10분 휴식
      current = end.addMinutes(10);
    }
    return blocks;
  }

  _Time? _parseStart(String freeTime) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(freeTime);
    if (match == null) return null;
    final h = int.tryParse(match.group(1) ?? '');
    final m = int.tryParse(match.group(2) ?? '');
    if (h == null || m == null) return null;
    return _Time(h, m);
  }
}

class _ScoredTask {
  final TaskItem task;
  final double score;
  _ScoredTask({required this.task, required this.score});
}

class _Time {
  final int hour;
  final int minute;
  const _Time(this.hour, this.minute);

  _Time addMinutes(int m) {
    final total = hour * 60 + minute + m;
    return _Time((total ~/ 60) % 24, total % 60);
  }

  String format() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
