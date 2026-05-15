import 'dart:math';
import 'package:flutter/material.dart';

// 마스코트(구조 고양이) 본체.
// 탭 시 살짝 bounce하고 표정이 랜덤하게 바뀐다.
//
// 악세서리 표시 정책 (현재 단계):
//   - 이 위젯은 "맨얼굴" 마스코트만 그린다.
//   - 모자/안경 같은 악세서리 이모지를 얼굴 위에 합성하지 않는다.
//     이모지 합성은 위치/크기가 어색해서 버그처럼 보일 수 있다.
//   - 착용 중인 아이템은 MascotBox 안에서 텍스트 뱃지로 표시한다.
//
// TODO(future): 실제 마스코트 PNG/SVG 에셋이 생기면 여기 Text 대신 Image를 쓰고,
//   악세서리도 Image.asset을 Stack의 Positioned로 정확한 좌표에 얹는다.
//   그때는 MascotBox의 _equippedBadges()를 제거하거나 보조 설명용으로만 둔다.

class MascotWidget extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;
  // 외부에서 표정을 고정하고 싶을 때 사용 (예: 결과 화면에서 구조율별 표정)
  final String? face;

  const MascotWidget({
    super.key,
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
    // 살짝 커졌다 작게 줄었다 원래대로 (gummy bounce)
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
    return GestureDetector(
      onTap: widget.onTap == null ? null : _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedSwitcher(
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
      ),
    );
  }
}
