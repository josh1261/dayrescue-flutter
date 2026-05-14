import 'package:flutter/material.dart';
import '../models/mascot_level.dart';
import 'mascot_widget.dart';

// 마스코트 카드 박스: 마스코트 + 레벨 배지 + 호칭 + RP 진행바 + 말풍선
// 홈/상점 화면에서 동일한 모습으로 쓰기 위한 공용 위젯.

class MascotBox extends StatelessWidget {
  final List<String> equippedIds;
  final int totalRp;
  final String quote;
  final VoidCallback? onMascotTap;
  final double mascotSize;
  final double circleSize;
  final bool showProgress;

  const MascotBox({
    super.key,
    required this.equippedIds,
    required this.totalRp,
    required this.quote,
    this.onMascotTap,
    this.mascotSize = 100,
    this.circleSize = 170,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final level = MascotLevel.fromRp(totalRp);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          children: [
            // 마스코트 + 원형 배경
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.deepPurple.shade50, Colors.indigo.shade50],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: MascotWidget(
                  equippedIds: equippedIds,
                  size: mascotSize,
                  onTap: onMascotTap,
                ),
              ),
            ),
            const SizedBox(height: 14),
            // 레벨 배지 + 호칭
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Lv.${level.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  level.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 진행바 + RP
            if (showProgress) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: level.progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '누적 $totalRp RP',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    level.isMax ? '만렙!' : '다음 레벨까지 +${level.rpToNext}',
                    style: TextStyle(
                      fontSize: 12,
                      color: level.isMax
                          ? Colors.deepPurple
                          : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // 말풍선
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Container(
                key: ValueKey(quote),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '"$quote"',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
