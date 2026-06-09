import 'package:flutter/material.dart';
import '../models/compressed_task.dart';

// 압축 결과 화면에서 한 할 일을 "오늘 어떻게 처리할지" 카드로 보여준다.
//  - 처리 유형(반드시/핵심/유지/최소/제외) 배지 + 색
//  - 실행 시간, 또는 제외 항목은 '내일로'
//  - 자연스러운 이유 문구
//  - "그래서 지금 뭘 하면 되는지" 다음 행동 안내
// 제외 항목은 실패가 아니라 '오늘은 전략적으로 내려놓은 일'로 차분하게 표현한다.

class PlanTaskCard extends StatelessWidget {
  final CompressedTask task;

  const PlanTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(task.processType);
    final excluded = task.isExcluded;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: excluded ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              excluded ? Colors.grey.shade200 : accent.withValues(alpha: 0.25),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 왼쪽 컬러 레일: 처리 유형을 한눈에.
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: excluded ? Colors.grey.shade300 : accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단: 처리 유형 배지 + 시간(또는 내일로)
                    Row(
                      children: [
                        _typeBadge(accent, excluded),
                        const Spacer(),
                        _timePill(accent, excluded),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // 할 일 이름
                    Text(
                      task.name,
                      style: TextStyle(
                        fontSize: 16.5,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: excluded
                            ? Colors.grey.shade600
                            : Colors.grey.shade900,
                      ),
                    ),
                    // 이유 문구
                    if (task.reason.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        task.reason,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // 다음 행동 안내
                    _nextActionBand(accent, excluded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 처리 유형 배지 (예: "핵심", 제외는 "오늘은 제외")
  Widget _typeBadge(Color accent, bool excluded) {
    final fg = excluded ? Colors.grey.shade600 : accent;
    final bg = excluded ? Colors.grey.shade200 : accent.withValues(alpha: 0.12);
    final label = excluded ? '오늘은 제외' : task.processLabel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(task.processType), size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  // 실행 시간 또는 '내일로'
  Widget _timePill(Color accent, bool excluded) {
    if (excluded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_repeat_rounded,
              size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(
            '내일로',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          task.time,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // 다음 행동을 눈에 띄는 띠로 표시
  Widget _nextActionBand(Color accent, bool excluded) {
    final fg = excluded ? Colors.grey.shade500 : accent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: excluded ? Colors.grey.shade100 : accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(
            excluded
                ? Icons.event_available_rounded
                : Icons.arrow_forward_rounded,
            size: 16,
            color: fg,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              task.nextActionHint,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _accentColor(ProcessType type) {
    return switch (type) {
      ProcessType.mandatory => Colors.red.shade600,
      ProcessType.core => Colors.deepPurple,
      ProcessType.keep => Colors.blue.shade600,
      ProcessType.minimum => Colors.orange.shade700,
      ProcessType.exclude => Colors.blueGrey,
    };
  }

  IconData _iconFor(ProcessType type) {
    return switch (type) {
      ProcessType.mandatory => Icons.push_pin_rounded,
      ProcessType.core => Icons.bolt_rounded,
      ProcessType.keep => Icons.task_alt_rounded,
      ProcessType.minimum => Icons.spa_rounded,
      ProcessType.exclude => Icons.event_repeat_rounded,
    };
  }
}
