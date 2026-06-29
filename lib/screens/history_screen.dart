import 'package:flutter/material.dart';
import '../models/rescue_record.dart';
import '../services/storage_service.dart';
import '../widgets/screen_shell.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storage = StorageService();
  List<RescueRecord>? _records;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await _storage.getRescueHistory();
    if (!mounted) return;
    setState(() => _records = records);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rescue 기록')),
      body: ScreenShell(child: _body()),
    );
  }

  Widget _body() {
    final records = _records;
    if (records == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (records.isEmpty) {
      return const Center(
        child: Text(
          '아직 저장된 Rescue 기록이 없습니다.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _RecordCard(record: records[index]),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final RescueRecord record;

  const _RecordCard({required this.record});

  String _formatDate(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}.$m.$d  $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final success = record.isSuccess;
    final color = success ? Colors.green.shade700 : Colors.orange.shade700;
    final bgColor = success ? Colors.green.shade50 : Colors.orange.shade50;
    final borderColor = success ? Colors.green.shade200 : Colors.orange.shade200;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 + 성공여부 배지
          Row(
            children: [
              Icon(Icons.access_time, size: 15, color: Colors.grey.shade500),
              const SizedBox(width: 5),
              Text(
                _formatDate(record.dateTime),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1.2),
                ),
                child: Text(
                  success ? '✓ 성공' : '✕ 미달',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 구조율 + RP
          Row(
            children: [
              _stat('${record.rescueRate}%', '구조율', Colors.deepPurple),
              const SizedBox(width: 16),
              _stat('+${record.earnedRp} RP', '획득 RP', Colors.deepPurple.shade300),
              const Spacer(),
              _stat(
                '${record.completedCount}/${record.totalCount}',
                '완료/전체',
                Colors.grey.shade700,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 성공 기준 텍스트
          Text(
            '성공 기준: ${record.successCriterionText}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
