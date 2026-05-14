// 압축 로직의 출력. 각 할 일을 어떻게 처리할지 결정한 결과.

enum ProcessType { mandatory, core, keep, minimum, exclude }

class CompressedTask {
  final int priority; // 1, 2, 3 ... ; 제외 항목은 -1
  final String name;
  final String time;
  final ProcessType processType;
  final int durationMinutes; // 실제 배치된 시간 (분)

  CompressedTask({
    required this.priority,
    required this.name,
    required this.time,
    required this.processType,
    this.durationMinutes = 0,
  });

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

  String get priorityLabel => priority == -1 ? '제외' : '$priority';
}
