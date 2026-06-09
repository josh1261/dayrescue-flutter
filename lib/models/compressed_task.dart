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

  // 카드 하단에 "그래서 지금 뭘 하면 되는지" 한 줄로 안내한다.
  String get nextActionHint {
    switch (processType) {
      case ProcessType.mandatory:
        return '시작 시간에 맞춰 그대로 지켜요';
      case ProcessType.core:
        return '가장 먼저, 가장 집중해서 끝내요';
      case ProcessType.keep:
        return '핵심을 끝낸 뒤 이어서 진행해요';
      case ProcessType.minimum:
        return '딱 $durationMinutes분만 가볍게 손대요';
      case ProcessType.exclude:
        return '오늘은 넘기고 내일 다시 봐요';
    }
  }

  String get priorityLabel => priority == -1 ? '제외' : '$priority';
}
