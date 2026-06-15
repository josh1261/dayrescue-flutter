// 압축 로직의 출력. 각 할 일을 어떻게 처리할지 결정한 결과.

enum ProcessType { mandatory, core, keep, minimum, exclude }

class CompressedTask {
  final int priority; // 1, 2, 3 ... ; 제외 항목은 -1
  final String name;
  final String time;
  final ProcessType processType;
  final int durationMinutes; // 실제 배치된 시간 (분)
  final String reason; // 왜 이렇게 분류했는지에 대한 사용자 친화적 설명

  CompressedTask({
    required this.priority,
    required this.name,
    required this.time,
    required this.processType,
    this.durationMinutes = 0,
    this.reason = '',
  });

  bool get isExcluded => processType == ProcessType.exclude;

  String get processLabel {
    switch (processType) {
      case ProcessType.mandatory:
        return '반드시';
      case ProcessType.core:
        return '핵심';
      case ProcessType.keep:
        return '유지';
      case ProcessType.minimum:
        return '최소';
      case ProcessType.exclude:
        return '제외';
    }
  }

  // 카드 하단에 "그래서 지금 뭘 하면 되는지" 한 줄로, 바로 실행할 행동을 안내한다.
  String get nextActionHint {
    switch (processType) {
      case ProcessType.mandatory:
        return '시작 시간 알림 맞춰두고 그대로 지켜요';
      case ProcessType.core:
        return '타이머 $durationMinutes분 맞추고 바로 시작해요';
      case ProcessType.keep:
        return '핵심 끝나면 바로 이어서 $durationMinutes분만 진행해요';
      case ProcessType.minimum:
        return '$durationMinutes분만 유지하고 멈춰도 성공이에요';
      case ProcessType.exclude:
        return '오늘은 미련 없이 내려놓아도 괜찮아요';
    }
  }

  String get priorityLabel => priority == -1 ? '제외' : '$priority';
}
