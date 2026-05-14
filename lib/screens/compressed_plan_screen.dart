import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../models/compressed_task.dart';
import '../models/diagnosis.dart';
import '../models/rescue_plan.dart';
import '../services/diagnosis_service.dart';
import '../services/plan_compressor.dart';
import '../widgets/diagnosis_card.dart';
import '../widgets/plan_task_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_shell.dart';
import 'completion_check_screen.dart';

// 압축 결과 화면.
// 상단: 진단 카드
// 중단: 두 플랜을 가로 카드로 나란히 비교 (활성/총시간 미리보기, 선택된 카드 강조)
// 하단: 선택된 플랜 상세 + CTA

class CompressedPlanScreen extends StatefulWidget {
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
  State<CompressedPlanScreen> createState() => _CompressedPlanScreenState();
}

class _CompressedPlanScreenState extends State<CompressedPlanScreen> {
  late final Diagnosis _diagnosis;
  late final RescuePlan _focusPlan;
  late final RescuePlan _minPlan;
  late PlanMode _previewMode;

  @override
  void initState() {
    super.initState();
    _diagnosis = DiagnosisService().diagnose(
      taskCount: widget.tasks.length,
      condition: widget.condition,
    );
    final compressor = PlanCompressor();
    _focusPlan = compressor.compress(
      mode: PlanMode.focusRecovery,
      tasks: widget.tasks,
      fixedSchedule: widget.fixedSchedule,
      freeTime: widget.freeTime,
      condition: widget.condition,
      mustDo: widget.mustDo,
    );
    _minPlan = compressor.compress(
      mode: PlanMode.minimumSurvival,
      tasks: widget.tasks,
      fixedSchedule: widget.fixedSchedule,
      freeTime: widget.freeTime,
      condition: widget.condition,
      mustDo: widget.mustDo,
    );
    // 컨디션 낮으면 최소 생존이 기본
    _previewMode = widget.condition < 40
        ? PlanMode.minimumSurvival
        : PlanMode.focusRecovery;
  }

  RescuePlan get _selectedPlan =>
      _previewMode == PlanMode.focusRecovery ? _focusPlan : _minPlan;

  void _start(PlanMode mode) {
    final plan = mode == PlanMode.focusRecovery ? _focusPlan : _minPlan;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompletionCheckScreen(tasks: plan.tasks),
      ),
    );
  }

  // 플랜 요약 카운트 (활성 항목 수)
  int _activeCount(RescuePlan plan) =>
      plan.tasks.where((t) => t.processType != ProcessType.exclude).length;

  // 플랜 총 시간 (분)
  int _totalMinutes(RescuePlan plan) => plan.tasks
      .where((t) =>
          t.processType != ProcessType.exclude &&
          t.processType != ProcessType.mandatory)
      .fold<int>(0, (sum, t) => sum + t.durationMinutes);

  @override
  Widget build(BuildContext context) {
    final plan = _selectedPlan;
    final active =
        plan.tasks.where((t) => t.processType != ProcessType.exclude).toList();
    final excluded =
        plan.tasks.where((t) => t.processType == ProcessType.exclude).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('압축 결과')),
      body: ScreenShell(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 진단 카드
                  DiagnosisCard(diagnosis: _diagnosis),
                  const SizedBox(height: 20),

                  _sectionLabel('플랜 선택'),
                  // 두 플랜을 가로로 나란히 비교
                  Row(
                    children: [
                      Expanded(child: _planChoiceCard(_focusPlan)),
                      const SizedBox(width: 10),
                      Expanded(child: _planChoiceCard(_minPlan)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _previewMode.tagline,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 성공 기준
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flag_outlined,
                            color: Colors.deepPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            plan.successCriteria,
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
                  const SizedBox(height: 20),

                  _sectionLabel('우선순위'),
                  if (active.isEmpty)
                    _emptyHint('남은 게 없어요. 오늘은 회복에 집중하세요.'),
                  for (final t in active) PlanTaskCard(task: t),

                  if (excluded.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _sectionLabel('제외'),
                    for (final t in excluded) PlanTaskCard(task: t),
                  ],

                  const SizedBox(height: 20),
                  _sectionLabel('시간 배치'),
                  _timeBlocksCard(plan.timeBlocks),
                ],
              ),
            ),
            // 하단 버튼: 메인 시작 + 수정
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: PrimaryButton(
                      label: '수정',
                      secondary: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: '${_previewMode.label}으로 시작',
                      icon: Icons.play_arrow,
                      onPressed: () => _start(_previewMode),
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

  // 비교 가능한 플랜 선택 카드 (탭하면 선택)
  Widget _planChoiceCard(RescuePlan plan) {
    final selected = _previewMode == plan.mode;
    final isFocus = plan.mode == PlanMode.focusRecovery;
    final activeCount = _activeCount(plan);
    final minutes = _totalMinutes(plan);

    return GestureDetector(
      onTap: () => setState(() => _previewMode = plan.mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.deepPurple : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isFocus
                      ? Icons.center_focus_strong_outlined
                      : Icons.shield_outlined,
                  size: 18,
                  color: selected ? Colors.deepPurple : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    plan.mode.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          selected ? Colors.deepPurple : Colors.black87,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle,
                      size: 18, color: Colors.deepPurple),
              ],
            ),
            const SizedBox(height: 10),
            // 활성 항목 / 총 시간
            Row(
              children: [
                _metricChip('$activeCount개', selected),
                const SizedBox(width: 6),
                _metricChip('$minutes분', selected),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricChip(String text, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.deepPurple : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
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

  Widget _emptyHint(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _timeBlocksCard(List<String> blocks) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < blocks.length; i++) ...[
              if (i > 0) Divider(height: 14, color: Colors.grey.shade100),
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
                    child: Text(blocks[i],
                        style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
