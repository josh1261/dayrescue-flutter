import 'package:flutter/material.dart';
import '../models/mascot_item.dart';

// 마스코트(구조 고양이) + 착용 아이템 아이콘을 표시한다.

class MascotWidget extends StatelessWidget {
  final List<String> equippedIds;
  final double size;
  final VoidCallback? onTap;

  const MascotWidget({
    super.key,
    this.equippedIds = const [],
    this.size = 80,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final equippedIcons = kMascotItems
        .where((it) => equippedIds.contains(it.id))
        .map((it) => it.icon)
        .toList();
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🐱', style: TextStyle(fontSize: size)),
          if (equippedIcons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                equippedIcons.join(' '),
                style: TextStyle(fontSize: size * 0.3),
              ),
            ),
        ],
      ),
    );
  }
}
