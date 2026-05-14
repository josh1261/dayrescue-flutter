import 'dart:math';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_shell.dart';
import 'input_screen.dart';

// 홈 화면: 마스코트가 hero. 카피 짧게, 버튼 명확하게.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 마스코트 터치 시 보여줄 동기부여 문구 (스펙 고정)
  static const _quotes = [
    "오늘은 다 하지 말고, 하나만 살리자.",
    "밀렸으면 줄이면 된다.",
    "완벽한 계획보다 실행 가능한 계획.",
    "작게 해도 0은 아니다.",
    "버릴 건 버리고, 살릴 것만 남기자.",
    "오늘의 목표는 복구다.",
  ];

  final _storage = StorageService();
  List<String> _equipped = [];
  String? _mascotQuote;

  @override
  void initState() {
    super.initState();
    _loadEquipped();
  }

  Future<void> _loadEquipped() async {
    final e = await _storage.getEquipped();
    if (!mounted) return;
    setState(() => _equipped = e);
  }

  void _showRandomQuote() {
    final r = Random();
    setState(() {
      _mascotQuote = _quotes[r.nextInt(_quotes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenShell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text('DayRescue',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              const Text('오늘 계획이 밀렸나요?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              const Text('남은 하루를 실행 가능한 크기로 줄여보세요.',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const Spacer(),
              // 큰 마스코트: 원형 배경으로 시선 집중
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: MascotWidget(
                      equippedIds: _equipped,
                      size: 110,
                      onTap: _showRandomQuote,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // 마스코트 말풍선
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    key: ValueKey(_mascotQuote ?? '__default__'),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _mascotQuote == null
                          ? Colors.grey.shade100
                          : Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _mascotQuote ?? '고양이를 눌러보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: _mascotQuote == null ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: '오늘 계획 압축하기',
                icon: Icons.compress,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InputScreen()),
                  );
                  // 흐름이 끝나고 돌아오면 착용 아이템 다시 로드
                  _loadEquipped();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
