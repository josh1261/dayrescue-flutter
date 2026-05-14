import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_shell.dart';
import '../widgets/task_card.dart';
import 'compressed_plan_screen.dart';

// 할 일 카드 분류 화면: 각 TaskItem마다 마감/손실/예상 시간 선택

class TaskClassificationScreen extends StatefulWidget {
  final List<TaskItem> tasks;
  final String fixedSchedule;
  final String freeTime;
  final int condition;
  final String mustDo;

  const TaskClassificationScreen({
    super.key,
    required this.tasks,
    required this.fixedSchedule,
    required this.freeTime,
    required this.condition,
    required this.mustDo,
  });

  @override
  State<TaskClassificationScreen> createState() =>
      _TaskClassificationScreenState();
}

class _TaskClassificationScreenState extends State<TaskClassificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('할 일 분류')),
      body: ScreenShell(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      '각 일의 마감 · 손실 · 시간을 골라주세요',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                  for (final t in widget.tasks)
                    TaskCard(task: t, onChanged: () => setState(() {})),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PrimaryButton(
                label: '압축 결과 보기',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CompressedPlanScreen(
                        tasks: widget.tasks,
                        fixedSchedule: widget.fixedSchedule,
                        freeTime: widget.freeTime,
                        condition: widget.condition,
                        mustDo: widget.mustDo,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
