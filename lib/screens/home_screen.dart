import 'dart:math';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/mascot_box.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_shell.dart';
import 'input_screen.dart';

// 홈 화면: 카피 + 마스코트 카드(레벨/진행바/말풍선) + 최근 기록 pill + CTA

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
  int _totalRp = 0;
  int _recentRate = 0;
  int _recentEarned = 0;
  bool _hasResult = false;
  String _quote = "밀렸으면 줄이면 된다.";

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final equipped = await _storage.getEquipped();
    final total = await _storage.getTotalRp();
    final rate = await _storage.getRecentRescueRate();
    final earned = await _storage.getRecentEarnedRp();
    final has = await _storage.hasAnyResult();
    if (!mounted) return;
    setState(() {
      _equipped = equipped;
      _totalRp = total;
      _recentRate = rate;
      _recentEarned = earned;
      _hasResult = has;
    });
  }

  void _showRandomQuote() {
    final r = Random();
    String next;
    // 같은 문구가 연속으로 나오지 않게
    do {
      next = _quotes[r.nextInt(_quotes.length)];
    } while (next == _quote && _quotes.length > 1);
    setState(() => _quote = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenShell(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 로고/앱 이름
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.shield,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'DayRescue',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              // 메인 카피
              const Text(
                '오늘 계획이 무너졌나요?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                '남은 하루를 진단하고, 실행 가능한 크기로 줄여보세요.',
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 20),
              // 마스코트 박스 (레벨/누적 RP/말풍선)
              MascotBox(
                equippedIds: _equipped,
                totalRp: _totalRp,
                quote: _quote,
                onMascotTap: _showRandomQuote,
              ),
              const SizedBox(height: 12),
              // 최근 기록 (이전 결과가 있을 때만)
              if (_hasResult) _recentRecord(),
              const SizedBox(height: 20),
              // CTA
              PrimaryButton(
                label: '오늘 계획 압축하기',
                icon: Icons.compress,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InputScreen()),
                  );
                  // 흐름이 끝나고 돌아오면 모든 상태 다시 로드
                  _loadAll();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // 최근 기록 pill (가로 2분할)
  Widget _recentRecord() {
    return Row(
      children: [
        Expanded(child: _recentTile('최근 구조율', '$_recentRate%')),
        const SizedBox(width: 8),
        Expanded(child: _recentTile('최근 획득', '+$_recentEarned RP')),
      ],
    );
  }

  Widget _recentTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}
