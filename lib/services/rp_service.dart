import '../models/compressed_task.dart';

// 완료 상태별 RP 계산.
// 반드시/핵심 항목을 완료하면 보너스 RP를 더 준다.

enum CompletionStatus { done, reduced, minimum, failed, dropped }

class RpService {
  // 한 항목을 완료/줄여서 완료/최소 완료 등으로 마쳤을 때 얻는 RP
  int rpFor({required ProcessType type, required CompletionStatus status}) {
    // 기본 상태별 RP
    final base = switch (status) {
      CompletionStatus.done => 3,
      CompletionStatus.reduced => 2,
      CompletionStatus.minimum => 1,
      CompletionStatus.failed => 0,
      CompletionStatus.dropped => 1,
    };

    // "완료"는 처리 타입 보너스가 기본을 대체
    if (status == CompletionStatus.done) {
      return switch (type) {
        ProcessType.mandatory => 5,
        ProcessType.core => 3,
        ProcessType.keep => 2,
        ProcessType.minimum => 1,
        ProcessType.exclude => 0,
      };
    }
    if (status == CompletionStatus.reduced) {
      return switch (type) {
        ProcessType.mandatory => 3,
        ProcessType.core => 2,
        ProcessType.keep => 1,
        ProcessType.minimum => 1,
        ProcessType.exclude => 0,
      };
    }
    if (status == CompletionStatus.minimum) {
      return type == ProcessType.exclude ? 0 : 1;
    }
    return base;
  }

  // 항목 하나가 줄 수 있는 최대 RP (구조율 계산용)
  int maxRpFor(ProcessType type) {
    return switch (type) {
      ProcessType.mandatory => 5,
      ProcessType.core => 3,
      ProcessType.keep => 2,
      ProcessType.minimum => 1,
      ProcessType.exclude => 0,
    };
  }

  String labelOf(CompletionStatus status) {
    return switch (status) {
      CompletionStatus.done => '완료',
      CompletionStatus.reduced => '줄여서 완료',
      CompletionStatus.minimum => '최소 완료',
      CompletionStatus.failed => '실패',
      CompletionStatus.dropped => '과감히 버림',
    };
  }
}
