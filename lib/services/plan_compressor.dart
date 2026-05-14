import '../models/task_item.dart';
import '../models/compressed_task.dart';
import '../models/rescue_plan.dart';

// 규칙 기반 압축기.
// 두 가지 PlanMode를 지원한다:
//   - focusRecovery: 핵심 살리고 루틴도 가볍게 유지 (기본)
//   - minimumSurvival: 꼭 살릴 일 + 마감 큰 손실만 남기고 나머지 제외
//
// 추후 AI API로 교체할 때 compress() 시그니처만 유지하면 호출부 손댈 일 없음.

class PlanCompressor {
  RescuePlan compress({
    required PlanMode mode,
    required List<TaskItem> tasks,
    required String fixedSchedule,
    required String freeTime,
    required int condition, // 0~100
    required String mustDo,
  }) {
    final mustDoNames = mustDo
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // 1) 점수 부여
    final scored = <_ScoredTask>[];
    for (final t in tasks) {
      double score = 0;
      if (mustDoNames.contains(t.name)) score += 100;
      if (t.deadline == Deadline.today) {
        score += 30;
      } else if (t.deadline == Deadline.tomorrow) {
        score += 15;
      } else if (t.deadline == Deadline.thisWeek) {
        score += 5;
      }
      if (t.loss == Loss.large) {
        score += 25;
      } else if (t.loss == Loss.medium) {
        score += 10;
      }
      if (condition < 50 && _isOptional(t.name)) score -= 20;
      scored.add(_ScoredTask(task: t, score: score));
    }

    // 2) 점수 내림차순 정렬
    scored.sort((a, b) => b.score.compareTo(a.score));

    // 3) 모드별로 처리 타입과 시간 결정
    final compressed = <CompressedTask>[];
    int priority = 1;

    for (final s in scored) {
      final t = s.task;
      final isMust = mustDoNames.contains(t.name);
      final urgent = t.deadline == Deadline.today && t.loss == Loss.large;

      ProcessType pType;
      int duration;

      if (mode == PlanMode.minimumSurvival) {
        // 최소 생존: must-do + urgent만 핵심으로 살리고 나머지는 거의 제외
        if (isMust || urgent) {
          pType = ProcessType.core;
          duration = _capDuration(t.estimatedMinutes, max: 30); // 더 짧게
        } else if (t.deadline == Deadline.today) {
          pType = ProcessType.minimum;
          duration = 15;
        } else {
          pType = ProcessType.exclude;
          duration = 0;
        }
      } else {
        // 집중 복구 (기본)
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
        if (condition < 40 && !isMust && !urgent && _isOptional(t.name)) {
          pType = ProcessType.minimum;
          duration = 15;
        }
        if (condition < 25 && !isMust && !urgent) {
          pType = ProcessType.exclude;
          duration = 0;
        }
      }

      final reason = _reasonFor(
        task: t,
        isMust: isMust,
        urgent: urgent,
        pType: pType,
        condition: condition,
        mode: mode,
      );

      compressed.add(CompressedTask(
        priority: pType == ProcessType.exclude ? -1 : priority,
        name: t.name,
        time: pType == ProcessType.exclude ? '오늘은 제외' : '$duration분',
        processType: pType,
        durationMinutes: duration,
        reason: reason,
      ));

      if (pType != ProcessType.exclude) priority++;
    }

    // 4) 고정 일정을 맨 위에 "반드시"로
    if (fixedSchedule.trim().isNotEmpty) {
      compressed.insert(
        0,
        CompressedTask(
          priority: 1,
          name: fixedSchedule.trim(),
          time: '고정',
          processType: ProcessType.mandatory,
          reason: '고정 일정이라 반드시 처리',
        ),
      );
      // 우선순위 다시 매기기 (제외는 제외 상태 유지)
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

    // 5) 성공 기준
    final criticalNames = compressed
        .where((c) =>
            c.processType == ProcessType.mandatory ||
            c.processType == ProcessType.core)
        .map((c) => c.name)
        .toList();
    final successCriteria = criticalNames.isEmpty
        ? '오늘은 무리하지 않고 컨디션 회복이 목표'
        : '${criticalNames.join(' + ')} 완료하면 성공';

    // 6) 시간 배치
    final timeBlocks = _buildTimeBlocks(
      compressed: compressed,
      fixedSchedule: fixedSchedule,
      freeTime: freeTime,
    );

    return RescuePlan(
      mode: mode,
      tasks: compressed,
      successCriteria: successCriteria,
      timeBlocks: timeBlocks,
    );
  }

  // 한 줄 이유 문구 생성
  String _reasonFor({
    required TaskItem task,
    required bool isMust,
    required bool urgent,
    required ProcessType pType,
    required int condition,
    required PlanMode mode,
  }) {
    if (pType == ProcessType.exclude) {
      if (condition < 25) return '컨디션이 너무 낮아 오늘은 미루기';
      if (mode == PlanMode.minimumSurvival) return '최소 생존이라 오늘은 잘라내기';
      return '남은 시간 대비 우선순위 낮음';
    }
    if (pType == ProcessType.mandatory) return '고정 일정이라 반드시 처리';
    if (isMust && urgent) return '오늘 꼭 살릴 일이고 손실도 큼';
    if (isMust) return '오늘 꼭 살릴 일로 선택';
    if (urgent) return '마감이 오늘이고 손실이 큼';
    if (pType == ProcessType.core) return '마감 가까워 핵심으로 처리';
    if (pType == ProcessType.keep) {
      if (_isOptional(task.name) && condition < 70) {
        return '컨디션 $condition점이라 짧게 유지';
      }
      return '오늘 마감 있어 유지';
    }
    if (pType == ProcessType.minimum) {
      return '루틴 끊기지 않게 15분만 유지';
    }
    return '';
  }

  bool _isOptional(String name) {
    final lower = name.toLowerCase();
    return lower.contains('운동') ||
        lower.contains('영어') ||
        lower.contains('취미') ||
        lower.contains('독서');
  }

  int _capDuration(int minutes, {required int max}) {
    if (minutes >= 120) return max;
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
    final start = _parseStart(freeTime) ?? const _Time(19, 0);
    var current = start;

    for (final t in compressed) {
      if (t.processType == ProcessType.mandatory) continue;
      if (t.processType == ProcessType.exclude) continue;
      final dur = t.durationMinutes;
      if (dur <= 0) continue;
      final end = current.addMinutes(dur);
      blocks.add('${current.format()}~${end.format()} ${t.name}');
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
