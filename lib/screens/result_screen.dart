import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_shell.dart';
import 'mascot_shop_screen.dart';

// 결과/RP 화면.
// 큰 구조율 → 마스코트(구조율별 표정 고정) → 반응 문구 → 획득/누적 → 복구 요약

class ResultScreen extends StatefulWidget {
  final int earnedRp;
  final int maxRp;
  final int savedCount;
  final int minimumCount;
  final int droppedCount;
  final int failedCount;

  const ResultScreen({
    super.key,
    required this.earnedRp,
    required this.maxRp,
    required this.savedCount,
    required this.minimumCount,
    required this.droppedCount,
    required this.failedCount,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _storage = StorageService();
  int _totalRp = 0;
  int _rate = 0;
  List<String> _equipped = [];
  bool _saved = false;
  bool _saveStarted = false; // 중복 저장 방지 가드

  @override
  void initState() {
    super.initState();
    _save();
  }

  Future<void> _save() async {
    // initState가 다시 호출되거나 hot reload 시 State가 재진입할 때
    // RP가 두 번 더해지는 사고를 막는다.
    if (_saveStarted) return;
    _saveStarted = true;

    _rate = widget.maxRp == 0
        ? 0
        : ((widget.earnedRp / widget.maxRp) * 100).round();

    // 1) 누적 RP에 오늘 획득분 더하기 (단일 출처: storage_service)
    final newTotal = await _storage.addRp(widget.earnedRp);
    // 2) 최근 결과 (획득 RP + 구조율 + 요약 문자열)
    await _storage.saveRecentResult(
      earnedRp: widget.earnedRp,
      rescueRate: _rate,
    );
    // 3) 마스코트 착용 정보 (표시용)
    final equipped = await _storage.getEquipped();

    if (!mounted) return;
    setState(() {
      _totalRp = newTotal;
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

  // 구조율별 마스코트 표정 고정
  String _face() {
    if (_rate >= 80) return '😻';
    if (_rate >= 50) return '😺';
    if (_rate >= 1) return '😸';
    return '🐱';
  }

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 큰 구조율 (가장 시선)
              _bigRescueRate(),
              const SizedBox(height: 18),
              // 마스코트 (구조율별 표정)
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _rateColor().withValues(alpha: 0.12),
                        Colors.deepPurple.shade50,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _rateColor().withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: MascotWidget(
                      equippedIds: _equipped,
                      size: 96,
                      face: _face(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // 큰 반응 문구
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.deepPurple.shade100),
                ),
                child: Text(
                  _reaction(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // 획득 RP + 누적 RP 두 박스
              Row(
                children: [
                  Expanded(
                    child: _miniStat('+${widget.earnedRp} RP', '오늘 획득',
                        Colors.deepPurple),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _miniStat('$_totalRp', '누적 RP', Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // 오늘의 복구 요약
              _rescueSummary(),
              const SizedBox(height: 22),
              PrimaryButton(
                label: '마스코트 꾸미기',
                icon: Icons.celebration,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MascotShopScreen()),
                  );
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

  // 큰 구조율 카드 (가장 눈에 띄게)
  Widget _bigRescueRate() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _rateColor().withValues(alpha: 0.12),
            _rateColor().withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rateColor().withValues(alpha: 0.30)),
      ),
      child: Column(
        children: [
          Text(
            '오늘 구조율',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_rate%',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: _rateColor(),
              letterSpacing: -1.5,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
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

  Widget _rescueSummary() {
    final rows = <_SummaryRow>[
      _SummaryRow('살린 일', widget.savedCount, '개',
          Icons.check_circle_outline, Colors.green.shade700),
      _SummaryRow('최소로 유지한 일', widget.minimumCount, '개',
          Icons.remove_circle_outline, Colors.orange.shade800),
      _SummaryRow('과감히 버린 일', widget.droppedCount, '개',
          Icons.delete_outline, Colors.blue.shade700),
      if (widget.failedCount > 0)
        _SummaryRow('실패한 일', widget.failedCount, '개',
            Icons.close, Colors.grey),
    ];
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('오늘의 복구 요약',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) Divider(height: 14, color: Colors.grey.shade100),
              _summaryRow(rows[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(_SummaryRow r) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: r.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(r.icon, size: 16, color: r.color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(r.label, style: const TextStyle(fontSize: 14)),
        ),
        Text(
          '${r.count}${r.unit}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: r.color,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow {
  final String label;
  final int count;
  final String unit;
  final IconData icon;
  final Color color;
  _SummaryRow(this.label, this.count, this.unit, this.icon, this.color);
}
