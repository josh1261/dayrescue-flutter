import 'package:flutter/material.dart';
import '../models/mascot_item.dart';
import '../models/mascot_level.dart';
import 'mascot_widget.dart';

// 마스코트 카드 박스.
// 구성 순서: 말풍선 → 마스코트 → 레벨/호칭 → 착용 아이템 뱃지 → 진행바
//
// 착용 아이템은 마스코트 얼굴 위에 합성하지 않고, 이 카드 안의 별도 영역에
// "착용 중: 작은 모자 🎩" 같은 텍스트 뱃지로 표시한다.
//
// TODO(future): 실제 마스코트 이미지 에셋이 생기면 MascotWidget에서
//   PNG/SVG로 악세서리를 정확한 좌표에 얹는 방식으로 교체하고,
//   여기 _equippedBadges()는 제거하거나 부가 정보로만 둔다.

class MascotBox extends StatelessWidget {
  final List<String> equippedIds;
  final int totalRp;
  final String quote;
  final VoidCallback? onMascotTap;
  final double mascotSize;
  final double circleSize;
  final bool showProgress;
  final bool compact;

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
            // 말풍선 (마스코트 위)
            _speechBubble(),
            const SizedBox(height: 4),
            // 마스코트 본체 (맨얼굴)
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
            // 착용 중 뱃지 (착용 아이템 있을 때만)
            if (equippedIds.isNotEmpty) ...[
              const SizedBox(height: 12),
              _equippedBadges(),
            ],
            // 진행바
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

  // "착용 중" 라벨 + 아이템별 뱃지 가로 나열
  Widget _equippedBadges() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '착용 중',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: equippedIds.map(_badge).toList(),
        ),
      ],
    );
  }

  // 아이템별 뱃지. 효과음은 시각 아이콘 대신 "효과음 적용 중" 라벨.
  Widget _badge(String id) {
    // 효과음은 별도 톤 (호박색)
    if (id == 'beep') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volume_up,
                size: 12, color: Colors.amber.shade800),
            const SizedBox(width: 4),
            Text(
              '효과음 적용 중',
              style: TextStyle(
                fontSize: 11,
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // 일반 시각 아이템: 이모지 + 이름
    final match = kMascotItems.where((it) => it.id == id);
    if (match.isEmpty) return const SizedBox.shrink();
    final item = match.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            item.name,
            style: TextStyle(
              fontSize: 11,
              color: Colors.deepPurple.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 말풍선 (마스코트 위에서 페이드인 + 꼬리)
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
