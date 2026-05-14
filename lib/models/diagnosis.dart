// 압축 결과 화면 상단에 보여줄 "오늘 진단" 결과 모델.
// DiagnosisService가 입력값을 받아 채워준다.

enum OverloadLevel { high, medium, low }
enum ConditionRating { low, medium, high }
enum RecoveryStrategy { minimum, core, focus }

class Diagnosis {
  final OverloadLevel overload;
  final int conditionScore; // 0~100
  final ConditionRating conditionRating;
  final RecoveryStrategy strategy;
  final String todayApproach; // 한 줄 추천 방식

  Diagnosis({
    required this.overload,
    required this.conditionScore,
    required this.conditionRating,
    required this.strategy,
    required this.todayApproach,
  });

  String get overloadLabel => switch (overload) {
        OverloadLevel.high => '높음',
        OverloadLevel.medium => '보통',
        OverloadLevel.low => '낮음',
      };

  String get conditionLabel => switch (conditionRating) {
        ConditionRating.low => '낮음',
        ConditionRating.medium => '보통',
        ConditionRating.high => '좋음',
      };

  String get strategyLabel => switch (strategy) {
        RecoveryStrategy.minimum => '최소 생존',
        RecoveryStrategy.core => '핵심 압축',
        RecoveryStrategy.focus => '집중 복구',
      };

  // 복구 전략의 한 줄 설명 (진단 카드의 4번째 줄)
  String get strategyDescription => switch (strategy) {
        RecoveryStrategy.minimum => '꼭 살릴 일만 남기고 나머지는 내려놓기',
        RecoveryStrategy.core => '핵심 1개 + 유지 루틴 1~2개',
        RecoveryStrategy.focus => '핵심 깊게 + 부가 루틴까지 가볍게',
      };
}
