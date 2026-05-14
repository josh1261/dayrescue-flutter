import 'package:flutter/material.dart';
import '../models/compressed_task.dart';
import '../services/rp_service.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_shell.dart';
import 'result_screen.dart';

// 완료 체크 화면.
// 각 항목 카드에 처리 유형/시간/예상 RP 표시.
// 칩에 "+N RP"를 함께 표시해서 어떤 선택이 얼마를 주는지 즉시 파악.

class CompletionCheckScreen extends StatefulWidget {
  final List<CompressedTask> tasks;
  const CompletionCheckScreen({super.key, required this.tasks});

  @override
  State<CompletionCheckScreen> createState() => _CompletionCheckScreenState();
}

class _CompletionCheckScreenState extends State<CompletionCheckScreen> {
  final _rp = RpService();
  late final List<CompressedTask> _shown =
      widget.tasks.where((t) => t.processType != ProcessType.exclude).toList();
  late final List<CompletionStatus> _statuses =
      List.filled(_shown.length, CompletionStatus.done);

  void _next() {
    int earned = 0;
    int max = 0;
    int saved = 0; // 완료 + 줄여서 완료
    int minimumDone = 0; // 최소 완료
    int dropped = 0; // 과감히 버림
    int failed = 0;

    for (var i = 0; i < _shown.length; i++) {
      final type = _shown[i].processType;
      final status = _statuses[i];
      earned += _rp.rpFor(type: type, status: status);
      max += _rp.maxRpFor(type);
      switch (status) {
        case CompletionStatus.done:
        case CompletionStatus.reduced:
          saved++;
        case CompletionStatus.minimum:
          minimumDone++;
        case CompletionStatus.dropped:
          dropped++;
        case CompletionStatus.failed:
          failed++;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          earnedRp: earned,
          maxRp: max,
          savedCount: saved,
          minimumCount: minimumDone,
          droppedCount: dropped,
          failedCount: failed,
        ),
      ),
    );
  }

  // 현재 화면에서 합산되는 예상 RP (상단 요약용)
  int get _previewEarned {
    int s = 0;
    for (var i = 0; i < _shown.length; i++) {
      s += _rp.rpFor(type: _shown[i].processType, status: _statuses[i]);
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('완료 체크')),
      body: ScreenShell(
        child: Column(
          children: [
            Expanded(
              child: _shown.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          '체크할 항목이 없어요.\n오늘은 컨디션 회복에 집중하세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, height: 1.5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _shown.length + 1,
                      itemBuilder: (context, idx) {
                        if (idx == 0) return _summaryHeader();
                        final i = idx - 1;
                        return _taskCard(i);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PrimaryButton(label: '오늘 결과 보기', onPressed: _next),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '각 항목의 결과를 선택하세요',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '현재 +$_previewEarned RP',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(int i) {
    final t = _shown[i];
    final selectedStatus = _statuses[i];
    final earned = _rp.rpFor(type: t.processType, status: selectedStatus);
    final processColor = _processColor(t.processType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: processColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      t.processLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: processColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t.time,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  // 현재 선택 시 받을 RP
                  Text(
                    earned > 0 ? '+$earned RP' : '0 RP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: earned > 0
                          ? Colors.deepPurple
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t.name,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in CompletionStatus.values)
                    _statusChip(i, s, t.processType),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 칩에 "라벨 +RP"를 함께 표시
  Widget _statusChip(int i, CompletionStatus s, ProcessType type) {
    final selected = _statuses[i] == s;
    final rp = _rp.rpFor(type: type, status: s);
    return ChoiceChip(
      label: Text(
        rp > 0 ? '${_rp.labelOf(s)} +$rp' : _rp.labelOf(s),
        style: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? Colors.white : Colors.black87,
        ),
      ),
      selected: selected,
      selectedColor: Colors.deepPurple,
      backgroundColor: Colors.grey.shade100,
      side: BorderSide(
        color: selected ? Colors.deepPurple : Colors.grey.shade300,
      ),
      onSelected: (_) => setState(() => _statuses[i] = s),
    );
  }

  Color _processColor(ProcessType type) => switch (type) {
        ProcessType.mandatory => Colors.red.shade700,
        ProcessType.core => Colors.deepPurple,
        ProcessType.keep => Colors.blue.shade700,
        ProcessType.minimum => Colors.orange.shade800,
        ProcessType.exclude => Colors.grey,
      };
}
