import 'package:flutter/material.dart';

// DayRescue 마스코트 위젯.
// face 값에 따라 기본/응원/성공/위로 이미지를 보여준다.
// 클릭 시에는 이미지가 바뀌지 않고, bounce 애니메이션과 onTap 콜백만 실행한다.
//
// 사용 예:
// MascotWidget(face: 'default')
// MascotWidget(face: 'cheer')
// MascotWidget(face: 'success')
// MascotWidget(face: 'comfort')

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
    switch (widget.face) {
      case 'cheer':
        return 'assets/images/mascot_cheer.png';
      case 'success':
        return 'assets/images/mascot_success.png';
      case 'comfort':
        return 'assets/images/mascot_comfort.png';
      case 'default':
      default:
        return 'assets/images/mascot_default.png';
    }
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
            errorBuilder: (context, error, stackTrace) {
              return const Text('🐱', style: TextStyle(fontSize: 64));
            },
          ),
        ),
      ),
    );
  }
}
