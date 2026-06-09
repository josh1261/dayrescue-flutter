import 'package:flutter/material.dart';

/// AppBar에서 홈 화면으로 돌아가는 버튼.
/// 현재 화면 스택의 가장 첫 화면까지 이동한다.
class HomeAction extends StatelessWidget {
  const HomeAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '홈으로',
      icon: const Icon(Icons.home_rounded),
      onPressed: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}
