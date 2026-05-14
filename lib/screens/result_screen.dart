import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_shell.dart';
import 'mascot_shop_screen.dart';

// 결과/RP 화면: 마스코트 hero + 큰 숫자 3개(획득/누적/구조율)

class ResultScreen extends StatefulWidget {
  final int earnedRp;
  final int maxRp;
  const ResultScreen({super.key, required this.earnedRp, required this.maxRp});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _storage = StorageService();
  int _totalRp = 0;
  int _rate = 0;
  List<String> _equipped = [];
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _save();
  }

  Future<void> _save() async {
    // 구조율 = 획득 / 최대 가능
    _rate = widget.maxRp == 0
        ? 0
        : ((widget.earnedRp / widget.maxRp) * 100).round();
    await _storage.addRp(widget.earnedRp);
    await _storage.setRecentRescueRate(_rate);
    await _storage.setRecentResult('+${widget.earnedRp} RP · 구조율 $_rate%');
    final total = await _storage.getTotalRp();
    final equipped = await _storage.getEquipped();
    if (!mounted) return;
    setState(() {
      _totalRp = total;
      _equipped = equipped;
      _saved = true;
    });
  }

  String _reaction() {
    if (_rate >= 80) return '핵심은 살렸어. 오늘은 성공이야.';
    if (_rate >= 50) return '완벽하진 않아도 하루를 복구했어.';
    if (_rate >= 1) return '작게라도 한 게 중요해. 내일은 더 줄여보자.';
    return '괜찮아. 다음 계획은 더 작게 만들자.';
  }

  // 구조율에 따른 강조 색
  Color _rateColor() {
    if (_rate >= 80) return Colors.green.shade700;
    if (_rate >= 50) return Colors.blue.shade700;
    if (_rate >= 1) return Colors.orange.shade700;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (!_saved) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘 결과'),
        automaticallyImplyLeading: false,
      ),
      body: ScreenShell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 큰 마스코트
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: MascotWidget(equippedIds: _equipped, size: 90),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // 마스코트 반응 문구
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _reaction(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // 큰 숫자 3개
              Row(
                children: [
                  Expanded(
                    child: _statBox(
                      '+${widget.earnedRp}',
                      '오늘 획득',
                      Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statBox(
                      '$_totalRp',
                      '누적 RP',
                      Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statBox(
                      '$_rate%',
                      '구조율',
                      _rateColor(),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                label: '마스코트 꾸미기',
                icon: Icons.celebration,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MascotShopScreen()),
                  );
                  // 상점에서 돌아오면 RP/착용 상태 다시 로드
                  final t = await _storage.getTotalRp();
                  final e = await _storage.getEquipped();
                  if (!mounted) return;
                  setState(() {
                    _totalRp = t;
                    _equipped = e;
                  });
                },
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: '홈으로',
                icon: Icons.home_outlined,
                secondary: true,
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 큰 숫자 박스 (스펙: 획득 RP / 누적 RP / 구조율을 크게 표시)
  Widget _statBox(String value, String label, Color color) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
