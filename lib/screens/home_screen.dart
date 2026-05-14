import 'dart:math';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/mascot_box.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_shell.dart';
import 'input_screen.dart';

// 홈 화면: 마스코트 박스가 화면 중앙에 hero로 들어감.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 마스코트 터치 시 도는 동기부여 문구 (v3 확장 풀)
  static const _quotes = [
    "오늘은 다 하지 말고 하나만 살리자.",
    "밀렸으면 줄이면 된다.",
    "완벽보다 복구가 먼저야.",
    "지금 10분만 해도 충분해.",
    "버릴 건 버리고 살릴 것만 남기자.",
    "작게라도 하면 오늘은 살아난다.",
    "핵심 하나만 끝내도 괜찮아.",
    "오늘의 목표는 성공이 아니라 복구야.",
  ];

  final _storage = StorageService();
  final _random = Random();
  List<String> _equipped = [];
  int _totalRp = 0;
  int _recentRate = 0;
  int _recentEarned = 0;
  bool _hasResult = false;
  String _quote = "오늘은 다 하지 말고 하나만 살리자.";

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

  void _shuffleQuote() {
    String next;
    do {
      next = _quotes[_random.nextInt(_quotes.length)];
    } while (next == _quote && _quotes.length > 1);
    setState(() => _quote = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenShell(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 로고 + 앱 이름
              _header(),
              const SizedBox(height: 18),
              // 메인 카피
              const Text(
                '오늘 계획이 무너졌나요?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '남은 하루를 진단하고,\n실행 가능한 크기로 줄여보세요.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              // 마스코트 박스 (hero)
              MascotBox(
                equippedIds: _equipped,
                totalRp: _totalRp,
                quote: _quote,
                onMascotTap: _shuffleQuote,
              ),
              const SizedBox(height: 12),
              // 최근 기록
              if (_hasResult) _recentRecord(),
              const SizedBox(height: 18),
              // CTA
              PrimaryButton(
                label: '오늘 계획 압축하기',
                icon: Icons.compress,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InputScreen()),
                  );
                  _loadAll();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
            ),
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withValues(alpha: 0.30),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.shield, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        const Text(
          'DayRescue',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.3),
        ),
      ],
    );
  }

  Widget _recentRecord() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.history, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '최근 기록',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '구조율 ',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          Text(
            '$_recentRate%',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          Container(
            width: 1,
            height: 12,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Text(
            '+$_recentEarned RP',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}
