import 'package:flutter/material.dart';

// DayRescue 마스코트 위젯.
// 기존 이모지 기반 고양이를 실제 PNG 에셋 기반 마스코트로 교체했다.
// 현재 기본 에셋:
// - assets/images/mascot_default.png
//
// TODO(future):
// - mascot_success.png
// - mascot_cheer.png
// - mascot_comfort.png
// 같은 표정별 에셋을 추가하면 face 값에 따라 이미지를 분기할 수 있다.

class MascotWidget extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;
  final String? face;

  const MascotWidget({super.key, this.size = 80, this.onTap, this.face});

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.10,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.10,
          end: 0.96,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.96,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 35,
      ),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.forward(from: 0);
    widget.onTap?.call();
  }

  String get _assetPath {
    // 지금은 기본 마스코트 1종만 사용한다.
    // face 값은 기존 호출부 호환을 위해 유지한다.
    return 'assets/images/mascot_default.png';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap == null ? null : _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Image.asset(
            _assetPath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
