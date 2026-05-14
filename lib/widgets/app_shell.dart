import 'dart:math' as math;
import 'package:flutter/material.dart';

// 데스크탑 Chrome에서 앱을 "폰 카드"처럼 가운데에 띄우는 래퍼.
// 좁은 화면(<700px)에서는 풀블리드.
// MaterialApp.builder에서 한 번만 감싼다.

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    final h = media.size.height;

    // 좁은 뷰포트: 모바일 그대로
    if (w < 700) return child;

    // 데스크탑 폰 프레임 사이즈 (Pixel/iPhone 기준)
    const frameW = 420.0;
    final frameH = math.min(900.0, h - 48);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFEAF6), Color(0xFFE3DCEC)],
        ),
      ),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: frameW,
            height: frameH,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF9FC),
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: 0.10),
                  blurRadius: 60,
                  offset: const Offset(0, 24),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(33),
              // MediaQuery를 프레임 사이즈로 덮어써서 내부 위젯이
              // "이게 실제 화면이다"라고 인식하게 만든다.
              child: MediaQuery(
                data: media.copyWith(
                  size: const Size(frameW, 900),
                  padding: EdgeInsets.zero,
                  viewPadding: EdgeInsets.zero,
                  viewInsets: EdgeInsets.zero,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
