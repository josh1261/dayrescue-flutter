import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_shell.dart';
import 'task_classification_screen.dart';

// 입력 화면: 4개 섹션 카드로 그룹화.
// "오늘 상태 점검" 느낌 — 폼 작성보다, 지친 상태에서도 빠르게 고를 수 있게
// 카드마다 빠른 입력 chip / 프리셋 버튼을 둔다.

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  // 데모 기본값 없이 실제 입력처럼 비워둔다. (안내는 hint + 빠른 입력 chip으로)
  final _tasksCtrl = TextEditingController();
  final _fixedCtrl = TextEditingController();
  final _freeCtrl = TextEditingController();
  final _mustCtrl = TextEditingController();
  double _condition = 60;

  // 빠른 입력 예시
  static const _taskExamples = ['공부, 운동, 영어', '과제, 시험공부, 청소', '업무, 공부, 휴식'];
  static const _freeTimeExamples = [
    '19:00~21:00',
    '19:00~23:00',
    '20:00~23:30',
  ];
  static const _defaultFreeTime = '19:00~23:00';

  @override
  void dispose() {
    _tasksCtrl.dispose();
    _fixedCtrl.dispose();
    _freeCtrl.dispose();
    _mustCtrl.dispose();
    super.dispose();
  }

  List<String> _parseTasks() => _tasksCtrl.text
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  String? _firstTaskName() {
    final tasks = _parseTasks();
    return tasks.isEmpty ? null : tasks.first;
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // "첫 번째 남은 일을 핵심으로" 보조 버튼
  void _useFirstTaskAsMust() {
    final first = _firstTaskName();
    if (first == null) {
      _snack("먼저 '오늘 남은 일'을 입력해주세요.");
      return;
    }
    setState(() => _mustCtrl.text = first);
  }

  void _next() {
    final names = _parseTasks();
    // 1) 오늘 남은 일은 필수
    if (names.isEmpty) {
      _snack('오늘 남은 일을 한 개 이상 입력해주세요.');
      return;
    }

    // 2) 자유 시간이 비어 있으면 기본값으로 처리
    var freeTime = _freeCtrl.text.trim();
    if (freeTime.isEmpty) {
      freeTime = _defaultFreeTime;
      _freeCtrl.text = freeTime;
      _snack('자유 시간을 비워둬서 기본값 $_defaultFreeTime으로 잡았어요.');
    }

    // 3) 꼭 살릴 일이 비어 있으면 첫 번째 남은 일을 핵심으로
    var mustDo = _mustCtrl.text.trim();
    if (mustDo.isEmpty) {
      mustDo = names.first;
      _mustCtrl.text = mustDo;
      _snack("오늘 꼭 살릴 일을 비워둬서 '$mustDo'을(를) 핵심으로 설정했어요.");
    }

    // 기존 데이터 구조 그대로 유지하여 전달
    final tasks = names.map((n) => TaskItem(name: n)).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskClassificationScreen(
          tasks: tasks,
          fixedSchedule: _fixedCtrl.text.trim(),
          freeTime: freeTime,
          condition: _condition.round(),
          mustDo: mustDo,
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
                // 하단 고정 버튼이 마지막 카드/자유 시간 chip을 가리지 않도록
                // 충분한 바닥 여백을 둔다.
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _header(),
                  _card(
                    icon: Icons.checklist_rounded,
                    title: '오늘 남은 일',
                    subtitle: '쉼표(,)로 여러 개',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _field(_tasksCtrl, hint: '예: 공부, 운동, 영어'),
                        const SizedBox(height: 12),
                        _quickLabel('이런 날도 있어요 — 눌러서 채우기'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final ex in _taskExamples)
                              _exampleChip(
                                ex,
                                () => setState(() => _tasksCtrl.text = ex),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _card(
                    icon: Icons.schedule_rounded,
                    title: '시간',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _labeledField(
                          '고정 일정',
                          _fixedCtrl,
                          hint: '예: 일 08:00~18:00 (없으면 비워두세요)',
                        ),
                        const SizedBox(height: 14),
                        _labeledField(
                          '자유 시간',
                          _freeCtrl,
                          hint: '예: 19:00~23:00 (비워두면 자동 설정)',
                        ),
                        const SizedBox(height: 10),
                        _quickLabel('자유 시간 빠른 선택'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final ex in _freeTimeExamples)
                              _exampleChip(
                                ex,
                                () => setState(() => _freeCtrl.text = ex),
                              ),
                          ],
                        ),
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
                            const Text(
                              '점',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: _conditionColor,
                            inactiveTrackColor: _conditionColor.withValues(
                              alpha: 0.15,
                            ),
                            thumbColor: _conditionColor,
                            overlayColor: _conditionColor.withValues(
                              alpha: 0.15,
                            ),
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _conditionPreset(25, '거의 방전'),
                            const SizedBox(width: 8),
                            _conditionPreset(50, '보통 이하'),
                            const SizedBox(width: 8),
                            _conditionPreset(70, '할 만함'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _card(
                    icon: Icons.flag_outlined,
                    title: '오늘 꼭 살릴 일',
                    subtitle: '여러 개면 쉼표로',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _field(_mustCtrl, hint: '예: 공부 (비워두면 첫 번째 일로 자동 설정)'),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _useFirstTaskAsMust,
                            icon: const Icon(
                              Icons.arrow_upward_rounded,
                              size: 16,
                            ),
                            label: const Text('첫 번째 남은 일을 핵심으로'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PrimaryButton(label: '오늘 구조 플랜 만들기', onPressed: _next),
            ),
          ],
        ),
      ),
    );
  }

  // 상단 안내 — 폼 느낌을 덜어주는 따뜻한 문구
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '다 끝내려 하지 말고,\n오늘 살릴 것만 골라볼게요.',
            style: TextStyle(
              fontSize: 17,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '지금 떠오르는 만큼만 적어도 충분해요. 빈칸은 알아서 채워둘게요.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Colors.grey.shade600,
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: 14),
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
                    child: Icon(
                      icon,
                      size: 16,
                      color: Colors.deepPurple.shade400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
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

  // 빠른 입력 안내용 작은 라벨
  Widget _quickLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11.5,
        color: Colors.grey.shade500,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // 탭하면 입력창을 채우는 가벼운 chip
  Widget _exampleChip(String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.deepPurple.shade100),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.deepPurple.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // 컨디션 빠른 선택 버튼 (현재 값과 같으면 강조)
  Widget _conditionPreset(int value, String label) {
    final selected = _condition.round() == value;
    final color = _conditionColor;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _condition = value.toDouble()),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.12)
                  : const Color(0xFFFAF9FC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? color : Colors.grey.shade200,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selected ? color : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: selected ? color : Colors.grey.shade500,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        _field(c, hint: hint),
      ],
    );
  }
}
