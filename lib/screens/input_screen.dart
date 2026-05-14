import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_shell.dart';
import 'task_classification_screen.dart';

// 입력 화면: 4개 섹션 카드로 그룹화.
// "오늘 상태 점검" 느낌 — 카드마다 작은 아이콘으로 무엇을 묻는지 즉시 보이게.

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

  // 컨디션 점수별 라벨 (사용자가 어떤 상태인지 즉시 인지)
  String get _conditionLabel {
    final v = _condition.round();
    if (v < 30) return '오늘은 많이 지쳤어요';
    if (v < 50) return '컨디션이 낮아요';
    if (v < 70) return '컨디션은 보통';
    return '컨디션 좋은 편';
  }

  Color get _conditionColor {
    final v = _condition.round();
    if (v < 30) return Colors.red.shade700;
    if (v < 50) return Colors.orange.shade800;
    if (v < 70) return Colors.blue.shade700;
    return Colors.green.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘 상태 점검')),
      body: ScreenShell(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 안내문 (짧게)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      '몇 가지 알려주면 오늘 하루를 진단해줄게요',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ),
                  _card(
                    icon: Icons.checklist_rounded,
                    title: '오늘 남은 일',
                    subtitle: '쉼표(,)로 여러 개',
                    child: _field(_tasksCtrl,
                        hint: '예: 전공공부, 영어공부, 운동, 일'),
                  ),
                  _card(
                    icon: Icons.schedule_rounded,
                    title: '시간',
                    child: Column(
                      children: [
                        _labeledField('고정 일정', _fixedCtrl,
                            hint: '예: 일 08:00~18:00'),
                        const SizedBox(height: 12),
                        _labeledField('자유 시간', _freeCtrl,
                            hint: '예: 19:00~23:30'),
                      ],
                    ),
                  ),
                  _card(
                    icon: Icons.favorite_outline,
                    title: '컨디션',
                    subtitle: _conditionLabel,
                    subtitleColor: _conditionColor,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${_condition.round()}',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: _conditionColor,
                                letterSpacing: -1,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('점',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: _conditionColor,
                            inactiveTrackColor:
                                _conditionColor.withValues(alpha: 0.15),
                            thumbColor: _conditionColor,
                            overlayColor:
                                _conditionColor.withValues(alpha: 0.15),
                          ),
                          child: Slider(
                            value: _condition,
                            min: 0,
                            max: 100,
                            divisions: 20,
                            label: _condition.round().toString(),
                            onChanged: (v) => setState(() => _condition = v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _card(
                    icon: Icons.flag_outlined,
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

  // 섹션 카드 (좌측 아이콘 + 타이틀 + 서브타이틀 + 본문)
  Widget _card({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon,
                        size: 16, color: Colors.deepPurple.shade400),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: subtitleColor ?? Colors.grey,
                              fontWeight: subtitleColor != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
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
        fillColor: const Color(0xFFFAF9FC),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
        ),
      ),
    );
  }

  Widget _labeledField(String label, TextEditingController c, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        _field(c, hint: hint),
      ],
    );
  }
}
