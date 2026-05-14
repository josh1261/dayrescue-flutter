import 'package:flutter/material.dart';
import '../models/compressed_task.dart';

// 압축 결과 화면의 각 할 일 카드.
// [처리 유형 chip] + 이름 + 시간 + 이유 한 줄

class PlanTaskCard extends StatelessWidget {
  final CompressedTask task;
  const PlanTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isExcluded = task.processType == ProcessType.exclude;
    final color = _colorFor(task.processType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        // 처리 유형별로 좌측 강조 라인
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 좌측 강조 띠 (처리 유형 컬러)
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 윗줄: [처리 유형] + 시간
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              task.processLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            task.time,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 할 일 이름
                      Text(
                        task.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isExcluded ? Colors.grey : Colors.black87,
                          decoration:
                              isExcluded ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.reason.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          '이유: ${task.reason}',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorFor(ProcessType type) => switch (type) {
        ProcessType.mandatory => Colors.red.shade700,
        ProcessType.core => Colors.deepPurple,
        ProcessType.keep => Colors.blue.shade700,
        ProcessType.minimum => Colors.orange.shade800,
        ProcessType.exclude => Colors.grey,
      };
}
