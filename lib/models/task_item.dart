// 사용자가 입력한 할 일 한 개를 표현하는 모델.
// 입력 화면에서 이름만 받고, 분류 화면에서 마감/손실/예상 시간을 채운다.

enum Deadline { today, tomorrow, thisWeek, none }
enum Loss { small, medium, large }

class TaskItem {
  final String name;
  Deadline deadline;
  Loss loss;
  int estimatedMinutes; // 15, 30, 60, 120(=2시간+)

  TaskItem({
    required this.name,
    this.deadline = Deadline.today,
    this.loss = Loss.medium,
    this.estimatedMinutes = 30,
  });

  String get deadlineLabel {
    switch (deadline) {
      case Deadline.today:
        return '오늘';
      case Deadline.tomorrow:
        return '내일';
      case Deadline.thisWeek:
        return '이번 주';
      case Deadline.none:
        return '없음';
    }
  }

  String get lossLabel {
    switch (loss) {
      case Loss.small:
        return '작음';
      case Loss.medium:
        return '보통';
      case Loss.large:
        return '큼';
    }
  }

  String get estimateLabel {
    if (estimatedMinutes >= 120) return '2시간+';
    return '$estimatedMinutes분';
  }
}
