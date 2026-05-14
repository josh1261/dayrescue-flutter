import '../models/diagnosis.dart';

// 규칙 기반 진단기.
// 추후 AI API로 교체할 때 이 service만 갈아끼우면 된다.

class DiagnosisService {
  Diagnosis diagnose({required int taskCount, required int condition}) {
    // 1) 계획 과부하 — 할 일 개수 기준
    final overload = taskCount >= 5
        ? OverloadLevel.high
        : taskCount >= 3
            ? OverloadLevel.medium
            : OverloadLevel.low;

    // 2) 컨디션 등급
    final rating = condition < 40
        ? ConditionRating.low
        : condition < 70
            ? ConditionRating.medium
            : ConditionRating.high;

    // 3) 복구 전략 (컨디션 기반)
    final strategy = condition < 40
        ? RecoveryStrategy.minimum
        : condition < 70
            ? RecoveryStrategy.core
            : RecoveryStrategy.focus;

    // 4) 오늘 방식 (과부하 × 컨디션 매트릭스)
    final approach = _approachFor(overload: overload, condition: condition);

    return Diagnosis(
      overload: overload,
      conditionScore: condition,
      conditionRating: rating,
      strategy: strategy,
      todayApproach: approach,
    );
  }

  // 과부하/컨디션 조합별 "오늘 방식" 추천 문구
  String _approachFor({required OverloadLevel overload, required int condition}) {
    if (overload == OverloadLevel.high && condition < 50) {
      return '전부 하지 말고 살릴 것만 남기기';
    }
    if (overload == OverloadLevel.high) {
      return '많이 줄이고 핵심에 집중';
    }
    if (overload == OverloadLevel.medium && condition < 40) {
      return '핵심 하나만 살리고 나머지는 최소';
    }
    if (overload == OverloadLevel.medium && condition >= 70) {
      return '핵심을 깊게 처리';
    }
    if (overload == OverloadLevel.medium) {
      return '핵심 위주로 줄여서 실행';
    }
    // overload low
    if (condition < 40) return '오늘은 회복이 우선';
    if (condition >= 70) return '여유 있게 깊게 가기';
    return '핵심을 차분히 끝내기';
  }
}
