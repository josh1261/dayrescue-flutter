import 'package:flutter/material.dart';

// 모든 화면의 body를 감싸는 모바일 폭 제한 래퍼.
// Chrome 창을 넓혀도 폰 폭(최대 480px)으로 유지되어 모바일 UX를 흉내낸다.

class ScreenShell extends StatelessWidget {
  final Widget child;
  const ScreenShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SafeArea(child: child),
      ),
    );
  }
}
