import 'package:flutter/material.dart';

// 화면 하단에 고정되는 액션 버튼 영역.
// 스크롤 콘텐츠 위에 떠 있는 느낌을 주기 위해 상단에 옅은 경계선을 두고,
// 버튼이 화면 끝/콘텐츠에 바짝 붙지 않도록 넉넉한 여백을 준다.
// (ScreenShell / SafeArea 안쪽에서 사용하므로 시스템 하단 인셋은 이미 처리됨)

class BottomActionBar extends StatelessWidget {
  final Widget child;
  const BottomActionBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9FC),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: child,
    );
  }
}
