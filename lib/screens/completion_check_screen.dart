import 'package:flutter/material.dart';
import '../models/compressed_task.dart';
import '../services/rp_service.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_shell.dart';
import 'result_screen.dart';

// 완료 체크 화면: 항목별로 완료 상태를 선택. 제외 항목은 표시하지 않음.

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
    for (var i = 0; i < _shown.length; i++) {
      earned += _rp.rpFor(type: _shown[i].processType, status: _statuses[i]);
      max += _rp.maxRpFor(_shown[i].processType);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(earnedRp: earned, maxRp: max),
      ),
    );
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
                        if (idx == 0) {
                          return const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              '각 항목의 결과를 선택하세요',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          );
                        }
                        final i = idx - 1;
                        final t = _shown[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          t.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${t.processLabel} · ${t.time}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.deepPurple.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      for (final s in CompletionStatus.values)
                                        ChoiceChip(
                                          label: Text(_rp.labelOf(s)),
                                          selected: _statuses[i] == s,
                                          onSelected: (_) =>
                                              setState(() => _statuses[i] = s),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
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
}
