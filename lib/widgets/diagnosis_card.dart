import 'package:flutter/material.dart';
import '../models/diagnosis.dart';

// 압축 결과 화면 상단에 표시하는 "오늘 진단" 카드.
// 앱이 사용자 상태를 읽어서 한 줄씩 코멘트하는 느낌을 준다.

class DiagnosisCard extends StatelessWidget {
  final Diagnosis diagnosis;
  const DiagnosisCard({super.key, required this.diagnosis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.deepPurple.shade50, Colors.indigo.shade50],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_information_outlined,
                  color: Colors.deepPurple),
              const SizedBox(width: 8),
              const Text(
                '오늘 진단',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _row(
            '계획 과부하',
            diagnosis.overloadLabel,
            _overloadColor(diagnosis.overload),
          ),
          _row(
            '컨디션',
            '${diagnosis.conditionScore}점 · ${diagnosis.conditionLabel}',
            _conditionColor(diagnosis.conditionRating),
          ),
          _row(
            '복구 전략',
            '${diagnosis.strategyLabel} · ${diagnosis.strategyDescription}',
            null,
          ),
          _row('오늘 방식', diagnosis.todayApproach, null, isLast: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color? valueColor,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _overloadColor(OverloadLevel level) => switch (level) {
        OverloadLevel.high => Colors.red.shade700,
        OverloadLevel.medium => Colors.orange.shade800,
        OverloadLevel.low => Colors.green.shade700,
      };

  Color _conditionColor(ConditionRating r) => switch (r) {
        ConditionRating.low => Colors.red.shade700,
        ConditionRating.medium => Colors.orange.shade800,
        ConditionRating.high => Colors.green.shade700,
      };
}
