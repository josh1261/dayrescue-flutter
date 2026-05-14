import 'dart:math';
import 'package:flutter/material.dart';
import '../models/mascot_item.dart';
import '../models/mascot_level.dart';
import '../services/storage_service.dart';
import '../widgets/mascot_box.dart';
import '../widgets/screen_shell.dart';

// 마스코트 꾸미기 화면.
// 마스코트 박스(레벨/RP/말풍선) + 광고 보상 + 아이템 해금/착용

class MascotShopScreen extends StatefulWidget {
  const MascotShopScreen({super.key});

  @override
  State<MascotShopScreen> createState() => _MascotShopScreenState();
}

class _MascotShopScreenState extends State<MascotShopScreen> {
  // 마스코트가 상점에서 던지는 "오늘 한마디" (홈과는 다른 톤)
  static const _shopQuotes = [
    "어떤 아이템이 마음에 들어?",
    "헬멧 쓰면 진짜 구조대원 같아!",
    "RP 모으는 거 잊지 마.",
    "내일도 함께 줄여보자.",
    "광고 보고 한 입씩 모으는 것도 방법.",
  ];

  final _storage = StorageService();
  int _rp = 0;
  List<String> _unlocked = [];
  List<String> _equipped = [];
  int _adUsed = 0;
  static const _adMax = 2;
  bool _loaded = false;
  String _quote = "어떤 아이템이 마음에 들어?";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rp = await _storage.getTotalRp();
    final u = await _storage.getUnlocked();
    final e = await _storage.getEquipped();
    final ad = await _storage.getAdRewardCount();
    if (!mounted) return;
    setState(() {
      _rp = rp;
      _unlocked = u;
      _equipped = e;
      _adUsed = ad;
      _loaded = true;
    });
  }

  void _shuffleQuote() {
    final r = Random();
    setState(() => _quote = _shopQuotes[r.nextInt(_shopQuotes.length)]);
  }

  Future<void> _unlock(MascotItem item) async {
    if (_rp < item.cost) return;
    await _storage.addRp(-item.cost);
    final next = [..._unlocked, item.id];
    await _storage.setUnlocked(next);
    await _load();
  }

  Future<void> _toggleEquip(MascotItem item) async {
    final next = [..._equipped];
    if (next.contains(item.id)) {
      next.remove(item.id);
    } else {
      next.add(item.id);
    }
    await _storage.setEquipped(next);
    await _load();
  }

  Future<void> _watchAd() async {
    if (_adUsed >= _adMax) return;
    // 실제 광고 SDK 미연결: +1 RP 즉시 지급
    await _storage.addRp(1);
    await _storage.incrementAdRewardCount();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('+1 RP 지급됐어요')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final level = MascotLevel.fromRp(_rp);

    return Scaffold(
      appBar: AppBar(title: const Text('마스코트 꾸미기')),
      body: ScreenShell(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // 마스코트 박스
            MascotBox(
              equippedIds: _equipped,
              totalRp: _rp,
              quote: _quote,
              onMascotTap: _shuffleQuote,
            ),
            const SizedBox(height: 20),
            // 레벨 정보 카드 (다음 레벨까지 +X RP)
            _levelInfoCard(level),
            const SizedBox(height: 20),
            // 광고 보상 카드
            _adRewardCard(),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                '아이템',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            for (final item in kMascotItems) _itemTile(item),
          ],
        ),
      ),
    );
  }

  Widget _levelInfoCard(MascotLevel level) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_outlined,
                color: Colors.deepPurple),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lv.${level.level} · ${level.title}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    level.isMax
                        ? '최고 레벨에 도달했어요'
                        : '다음 레벨까지 +${level.rpToNext} RP',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adRewardCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.ondemand_video, color: Colors.amber.shade800),
              const SizedBox(width: 8),
              const Text(
                '광고 보상',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '오늘 남은 광고 보상: ${_adMax - _adUsed}/$_adMax',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.amber.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _adUsed >= _adMax ? null : _watchAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('광고 보고 +1 RP 받기'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemTile(MascotItem item) {
    final unlocked = _unlocked.contains(item.id);
    final equipped = _equipped.contains(item.id);
    final canBuy = _rp >= item.cost;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(item.icon,
                    style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('${item.cost} RP',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              SizedBox(
                height: 36,
                child: unlocked
                    ? ElevatedButton(
                        onPressed: () => _toggleEquip(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: equipped
                              ? Colors.deepPurple
                              : Colors.deepPurple.shade50,
                          foregroundColor:
                              equipped ? Colors.white : Colors.deepPurple,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(equipped ? '착용 중' : '착용'),
                      )
                    : ElevatedButton(
                        onPressed: canBuy ? () => _unlock(item) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canBuy
                              ? Colors.deepPurple
                              : Colors.grey.shade200,
                          foregroundColor:
                              canBuy ? Colors.white : Colors.grey,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('해금'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
