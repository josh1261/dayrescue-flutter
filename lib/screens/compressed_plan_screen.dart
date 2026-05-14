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
// 중단: 플랜 토글 (집중 복구 / 최소 생존) + 선택된 플랜 미리보기
// 하단: 두 가지 시작 버튼

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

    // 진단 먼저
    _diagnosis = DiagnosisService().diagnose(
      taskCount: widget.tasks.length,
      condition: widget.condition,
    );

    // 두 플랜 모두 미리 계산
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

    // 컨디션 따라 기본 추천 플랜 결정
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

                  // 플랜 토글
                  _planToggle(),
                  const SizedBox(height: 8),
                  Text(
                    _previewMode.tagline,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),

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
            // 하단 버튼 영역
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  // 메인 시작 버튼: 현재 선택된 모드
                  PrimaryButton(
                    label: '${_previewMode.label}으로 시작',
                    icon: Icons.play_arrow,
                    onPressed: () => _start(_previewMode),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: '수정',
                          secondary: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 반대편 모드로 바로 시작하는 옵션
                      Expanded(
                        child: PrimaryButton(
                          label: '${_otherMode().label}으로 시작',
                          secondary: true,
                          onPressed: () => _start(_otherMode()),
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
    );
  }

  PlanMode _otherMode() => _previewMode == PlanMode.focusRecovery
      ? PlanMode.minimumSurvival
      : PlanMode.focusRecovery;

  // 두 플랜 사이를 토글하는 segmented 위젯
  Widget _planToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleTile(PlanMode.focusRecovery)),
          Expanded(child: _toggleTile(PlanMode.minimumSurvival)),
        ],
      ),
    );
  }

  Widget _toggleTile(PlanMode mode) {
    final selected = _previewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _previewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          mode.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.deepPurple : Colors.grey.shade600,
          ),
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
                    child: Text(
                      blocks[i],
                      style: const TextStyle(fontSize: 14),
                    ),
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
