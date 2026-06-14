import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../services/plan_compressor.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/home_action.dart';
import '../widgets/plan_task_card.dart';
import '../widgets/primary_button.dart';
import 'completion_check_screen.dart';

// 압축 결과 화면: "오늘의 구조 플랜"
//  - 성공 기준 → 오늘 처리할 일(카드) → 오늘의 실행 순서 → 잠시 내려놓기(제외)
// 압축 로직은 PlanCompressor에 위임한다. (나중에 AI API로 교체 가능)
// planId는 한 번만 생성되어 같은 압축 결과를 재확정해도 동일한 ID로 RP 중복 지급을 막는다.

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
  late final CompressionResult _result;

  @override
  void initState() {
    super.initState();
    _result = PlanCompressor().compress(
      tasks: widget.tasks,
      fixedSchedule: widget.fixedSchedule,
      freeTime: widget.freeTime,
      condition: widget.condition,
      mustDo: widget.mustDo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = _result.tasks.where((t) => !t.isExcluded).toList();
    final excluded = _result.tasks.where((t) => t.isExcluded).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 구조 플랜'),
        actions: const [HomeAction()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                // 하단 고정 버튼이 마지막 카드를 가리지 않도록 바닥 여백 확보
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Text(
                    '결정은 그대로 두고, 오늘 실행할 수 있는 크기로 줄였어요.',
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _successCard(),
                  const SizedBox(height: 24),

                  // 오늘 처리할 일 (카드)
                  _sectionHeading('오늘 처리할 일'),
                  const SizedBox(height: 8),
                  if (active.isEmpty)
                    _emptyHint('오늘은 무리하지 않기로 했어요. 컨디션 회복에 집중해요.')
                  else
                    for (final t in active) PlanTaskCard(task: t),

                  // 오늘의 실행 순서
                  if (_result.timeBlocks.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _sectionHeading(
                      '오늘의 실행 순서',
                      caption: '위에서부터 순서대로, 사이사이 잠깐 쉬어가도 좋아요.',
                    ),
                    const SizedBox(height: 12),
                    _executionTimeline(_result.timeBlocks),
                  ],

                  // 잠시 내려놓기 (제외)
                  if (excluded.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _sectionHeading(
                      '잠시 내려놓기',
                      caption:
                          '미룬 게 아니라, 오늘 더 중요한 일에 집중하려고 비워둔 거예요. 내일 다시 만나요.',
                    ),
                    const SizedBox(height: 8),
                    for (final t in excluded) PlanTaskCard(task: t),
                  ],
                ],
              ),
            ),
            BottomActionBar(
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CompletionCheckScreen(tasks: _result.tasks),
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

  // 오늘의 성공 기준 박스
  Widget _successCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.flag_rounded, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 성공 기준',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _result.successCriteria,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title, {String? caption}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 4),
          Text(
            caption,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _emptyHint(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  // 번호가 매겨진 타임라인. 항목 사이를 세로선으로 잇는다.
  Widget _executionTimeline(List<String> blocks) {
    return Column(
      children: [
        for (var i = 0; i < blocks.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    _stepCircle(i + 1),
                    if (i != blocks.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.deepPurple.shade100,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 3,
                      bottom: i == blocks.length - 1 ? 0 : 16,
                    ),
                    child: _stepText(blocks[i]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _stepCircle(int n) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      alignment: Alignment.center,
      child: Text(
        '$n',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  // "19:00~19:30 운동" 형태면 시간 부분을 강조한다.
  Widget _stepText(String block) {
    final match = RegExp(
      r'^(\d{1,2}:\d{2}~\d{1,2}:\d{2})\s+(.*)$',
    ).firstMatch(block);
    final baseStyle = TextStyle(
      fontSize: 14,
      height: 1.4,
      color: Colors.grey.shade800,
    );
    if (match == null) {
      return Text(block, style: baseStyle);
    }
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(
            text: '${match.group(1)}  ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.deepPurple,
            ),
          ),
          TextSpan(text: match.group(2)),
        ],
      ),
    );
  }
}
