import 'package:flutter/material.dart';
import '../models/task_item.dart';

// 분류 화면에서 각 할 일을 표시하는 카드.
// 마감/손실/예상 시간을 ChoiceChip으로 고르게 한다.

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onChanged;

  const TaskCard({super.key, required this.task, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _section('마감', [
              for (final d in Deadline.values)
                _chip(_deadlineLabel(d), task.deadline == d, () {
                  task.deadline = d;
                  onChanged();
                })
            ]),
            const SizedBox(height: 10),
            _section('손실', [
              for (final l in Loss.values)
                _chip(_lossLabel(l), task.loss == l, () {
                  task.loss = l;
                  onChanged();
                })
            ]),
            const SizedBox(height: 10),
            _section('예상 시간', [
              for (final m in [15, 30, 60, 120])
                _chip(m >= 120 ? '2시간+' : '$m분',
                    task.estimatedMinutes == m, () {
                  task.estimatedMinutes = m;
                  onChanged();
                })
            ]),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: children),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }

  String _deadlineLabel(Deadline d) {
    switch (d) {
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

  String _lossLabel(Loss l) {
    switch (l) {
      case Loss.small:
        return '작음';
      case Loss.medium:
        return '보통';
      case Loss.large:
        return '큼';
    }
  }
}
