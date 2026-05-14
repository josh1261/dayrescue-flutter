import 'dart:math';
import 'package:flutter/material.dart';
import '../models/mascot_item.dart';

// 마스코트(구조 고양이) + 착용 아이템 + 탭 시 bounce/표정 변화 애니메이션.
// 단순 위젯이 아니라 살짝 살아있는 캐릭터처럼 느껴지게.

class MascotWidget extends StatefulWidget {
  final List<String> equippedIds;
  final double size;
  final VoidCallback? onTap;
  // 외부에서 표정을 고정하고 싶을 때 사용 (예: 결과 화면에서 80%↑이면 😺)
  final String? face;

  const MascotWidget({
    super.key,
    this.equippedIds = const [],
    this.size = 80,
    this.onTap,
    this.face,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  // 탭마다 랜덤하게 도는 표정 풀
  static const _faces = ['🐱', '😺', '😸', '😻', '😼'];

  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  String _currentFace = '🐱';
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _currentFace = widget.face ?? '🐱';
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    // 살짝 커졌다가 작게 줄었다가 원래대로 (gummy bounce)
    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.18)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 1.18, end: 0.94)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 35),
      TweenSequenceItem(
          tween: Tween(begin: 0.94, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 35),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(covariant MascotWidget old) {
    super.didUpdateWidget(old);
    // 외부 face가 바뀌면 동기화
    if (widget.face != null && widget.face != _currentFace) {
      setState(() => _currentFace = widget.face!);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.forward(from: 0);
    // 외부에서 face를 고정하지 않은 경우에만 랜덤 교체
    if (widget.face == null) {
      String next;
      do {
        next = _faces[_random.nextInt(_faces.length)];
      } while (next == _currentFace);
      setState(() => _currentFace = next);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final equippedIcons = kMascotItems
        .where((it) => widget.equippedIds.contains(it.id))
        .map((it) => it.icon)
        .toList();

    return GestureDetector(
      onTap: widget.onTap == null ? null : _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: Tween(begin: 0.7, end: 1.0).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                ),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                _currentFace,
                key: ValueKey(_currentFace),
                style: TextStyle(fontSize: widget.size, height: 1.0),
              ),
            ),
            if (equippedIcons.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  equippedIcons.join(' '),
                  style: TextStyle(fontSize: widget.size * 0.3, height: 1.0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
