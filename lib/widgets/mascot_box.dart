import 'package:flutter/material.dart';
import '../models/mascot_level.dart';
import 'mascot_widget.dart';

// 마스코트 카드 박스.
// 구성: 말풍선 → 큰 마스코트 → 레벨 배지/호칭 → RP 진행바
// 말풍선은 마스코트 위쪽에 두고 꼬리가 아래(마스코트 방향)로 향한다.

class MascotBox extends StatelessWidget {
  final List<String> equippedIds;
  final int totalRp;
  final String quote;
  final VoidCallback? onMascotTap;
  final double mascotSize;
  final double circleSize;
  final bool showProgress;
  final bool compact; // true면 상점 화면용 작은 버전

  const MascotBox({
    super.key,
    required this.equippedIds,
    required this.totalRp,
    required this.quote,
    this.onMascotTap,
    this.mascotSize = 110,
    this.circleSize = 180,
    this.showProgress = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final level = MascotLevel.fromRp(totalRp);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, compact ? 16 : 20, 20, 18),
        child: Column(
          children: [
            // 말풍선 (마스코트 위쪽, 꼬리가 아래로)
            _speechBubble(),
            const SizedBox(height: 4),
            // 마스코트 + 원형 그라데이션 배경
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade50,
                    Colors.indigo.shade50.withValues(alpha: 0.6),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
                    ),
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
            if (showProgress) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: level.progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple),
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    level.isMax ? '만렙!' : '다음 레벨까지 +${level.rpToNext}',
                    style: TextStyle(
                      fontSize: 12,
                      color: level.isMax ? Colors.deepPurple : Colors.grey,
                      fontWeight: FontWeight.w500,
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

  // 말풍선 (위에서 페이드인 + 꼬리)
  Widget _speechBubble() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SizeTransition(
          sizeFactor: anim,
          axisAlignment: -1.0,
          child: child,
        ),
      ),
      child: Column(
        key: ValueKey(quote),
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.deepPurple.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              quote,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // 꼬리 (위쪽 마스코트를 가리키는 작은 삼각형)
          CustomPaint(
            size: const Size(14, 8),
            painter: _BubbleTailPainter(
              fillColor: Colors.white,
              borderColor: Colors.deepPurple.shade100,
            ),
          ),
        ],
      ),
    );
  }
}

// 말풍선 아래쪽 꼬리 (역삼각형)
class _BubbleTailPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  _BubbleTailPainter({required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_BubbleTailPainter old) =>
      old.fillColor != fillColor || old.borderColor != borderColor;
}
