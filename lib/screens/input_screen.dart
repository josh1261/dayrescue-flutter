import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_shell.dart';
import 'task_classification_screen.dart';

// 입력 화면: 5개 항목을 4개 카드로 그룹화해서 한눈에 보이게.

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _tasksCtrl = TextEditingController(text: '전공공부, 영어공부, 운동, 일');
  final _fixedCtrl = TextEditingController(text: '일 08:00~18:00');
  final _freeCtrl = TextEditingController(text: '19:00~23:30');
  final _mustCtrl = TextEditingController(text: '전공공부');
  double _condition = 60;

  @override
  void dispose() {
    _tasksCtrl.dispose();
    _fixedCtrl.dispose();
    _freeCtrl.dispose();
    _mustCtrl.dispose();
    super.dispose();
  }

  void _next() {
    final names = _tasksCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (names.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오늘 남은 일을 한 개 이상 입력해주세요.')),
      );
      return;
    }
    final tasks = names.map((n) => TaskItem(name: n)).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskClassificationScreen(
          tasks: tasks,
          fixedSchedule: _fixedCtrl.text,
          freeTime: _freeCtrl.text,
          condition: _condition.round(),
          mustDo: _mustCtrl.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘 상황 입력')),
      body: ScreenShell(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _card(
                    title: '오늘 남은 일',
                    subtitle: '쉼표(,)로 여러 개 입력',
                    child: _field(_tasksCtrl, hint: '예: 전공공부, 영어공부, 운동, 일'),
                  ),
                  _card(
                    title: '시간',
                    child: Column(
                      children: [
                        _labeledField('고정 일정', _fixedCtrl, hint: '예: 일 08:00~18:00'),
                        const SizedBox(height: 12),
                        _labeledField('자유 시간', _freeCtrl, hint: '예: 19:00~23:30'),
                      ],
                    ),
                  ),
                  _card(
                    title: '컨디션',
                    subtitle: '0 (피곤) ~ 100 (쌩쌩)',
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${_condition.round()}',
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('점',
                                style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                        Slider(
                          value: _condition,
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: _condition.round().toString(),
                          onChanged: (v) => setState(() => _condition = v),
                        ),
                      ],
                    ),
                  ),
                  _card(
                    title: '오늘 꼭 살릴 일',
                    subtitle: '여러 개면 쉼표로',
                    child: _field(_mustCtrl, hint: '예: 전공공부'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PrimaryButton(label: '할 일 분류하기', onPressed: _next),
            ),
          ],
        ),
      ),
    );
  }

  // 섹션 카드
  Widget _card({required String title, String? subtitle, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, {String? hint}) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _labeledField(String label, TextEditingController c, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 4),
        _field(c, hint: hint),
      ],
    );
  }
}
