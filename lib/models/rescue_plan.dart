import 'compressed_task.dart';

// 압축 결과 묶음. PlanMode로 두 가지 버전을 만든다.

enum PlanMode { focusRecovery, minimumSurvival }

extension PlanModeLabel on PlanMode {
  String get label => switch (this) {
        PlanMode.focusRecovery => '집중 복구',
        PlanMode.minimumSurvival => '최소 생존',
      };

  String get tagline => switch (this) {
        PlanMode.focusRecovery => '오늘 핵심을 살리고 루틴까지 가볍게 유지하는 버전',
        PlanMode.minimumSurvival => '컨디션 낮을 때, 살릴 일만 남기는 최소 버전',
      };
}

class RescuePlan {
  final PlanMode mode;
  final List<CompressedTask> tasks;
  final String successCriteria;
  final List<String> timeBlocks;

  RescuePlan({
    required this.mode,
    required this.tasks,
    required this.successCriteria,
    required this.timeBlocks,
  });
}
