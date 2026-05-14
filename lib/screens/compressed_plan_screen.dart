import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../models/compressed_task.dart';
import '../services/plan_compressor.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_shell.dart';
import 'completion_check_screen.dart';

// 압축 결과 화면: 카드 리스트 + 성공 기준 강조 + 시간 배치
// 압축 로직은 PlanCompressor에 위임. 나중에 AI API로 교체 가능.

class CompressedPlanScreen extends StatelessWidget {
  final List<TaskItem> tasks;
  final String fixedSchedule;
  final String freeTime;
  final int condition;
  final String mustDo;

  const CompressedPlanScreen({
    super.key,
    required this.tasks,
    required this.fixedSchedule,
    required this.freeTime,
    required this.condition,
    required this.mustDo,
  });

  @override
  Widget build(BuildContext context) {
    final result = PlanCompressor().compress(
      tasks: tasks,
      fixedSchedule: fixedSchedule,
      freeTime: freeTime,
      condition: condition,
      mustDo: mustDo,
    );

    // 활성/제외 분리해서 시각적으로 구분
    final active =
        result.tasks.where((t) => t.processType != ProcessType.exclude).toList();
    final excluded =
        result.tasks.where((t) => t.processType == ProcessType.exclude).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('압축 결과')),
      body: ScreenShell(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 성공 기준 강조
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flag_outlined, color: Colors.deepPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            result.successCriteria,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel('우선순위'),
                  for (final t in active) _taskCard(t),
                  if (excluded.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _sectionLabel('제외'),
                    for (final t in excluded) _taskCard(t),
                  ],
                  const SizedBox(height: 24),
                  _sectionLabel('시간 배치'),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < result.timeBlocks.length; i++) ...[
                            if (i > 0)
                              Divider(height: 14, color: Colors.grey.shade100),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    result.timeBlocks[i],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: '수정하기',
                      secondary: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: '이대로 시작',
                      icon: Icons.play_arrow,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CompletionCheckScreen(tasks: result.tasks),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // 각 할 일 카드 (우선순위 배지 + 이름 + 시간 + 처리 칩)
  Widget _taskCard(CompressedTask t) {
    final isExcluded = t.processType == ProcessType.exclude;
    final color = _colorFor(t.processType);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // 우선순위 배지 (제외는 X)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isExcluded
                      ? Colors.grey.shade100
                      : color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  isExcluded ? '✕' : '${t.priority}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isExcluded ? Colors.grey : color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 본문
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isExcluded ? Colors.grey : Colors.black87,
                        decoration:
                            isExcluded ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (!isExcluded) ...[
                          Text(
                            t.time,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            t.processLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorFor(ProcessType type) {
    return switch (type) {
      ProcessType.mandatory => Colors.red.shade700,
      ProcessType.core => Colors.deepPurple,
      ProcessType.keep => Colors.blue.shade700,
      ProcessType.minimum => Colors.orange.shade800,
      ProcessType.exclude => Colors.grey,
    };
  }
}
