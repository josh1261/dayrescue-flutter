import 'dart:math';
import 'package:flutter/material.dart';
import '../models/mascot_item.dart';
import '../services/storage_service.dart';
import '../widgets/mascot_box.dart';
import '../widgets/screen_shell.dart';

// 마스코트 꾸미기 화면.
// 상단에 MascotBox(레벨/RP/말풍선까지 다 들어감) → 광고 → 아이템 그리드/리스트

class MascotShopScreen extends StatefulWidget {
  const MascotShopScreen({super.key});

  @override
  State<MascotShopScreen> createState() => _MascotShopScreenState();
}

class _MascotShopScreenState extends State<MascotShopScreen> {
  // 상점 톤의 한마디 풀
  static const _shopQuotes = [
    "어떤 아이템이 마음에 들어?",
    "헬멧 쓰면 진짜 구조대원 같아!",
    "RP 모으는 거 잊지 마.",
    "내일도 함께 줄여보자.",
    "광고 보고 한 입씩 모으는 것도 방법.",
  ];

  final _storage = StorageService();
  final _random = Random();
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
    String next;
    do {
      next = _shopQuotes[_random.nextInt(_shopQuotes.length)];
    } while (next == _quote && _shopQuotes.length > 1);
    setState(() => _quote = next);
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
    return Scaffold(
      appBar: AppBar(title: const Text('마스코트 꾸미기')),
      body: ScreenShell(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            MascotBox(
              equippedIds: _equipped,
              totalRp: _rp,
              quote: _quote,
              onMascotTap: _shuffleQuote,
              compact: true,
              mascotSize: 90,
              circleSize: 150,
            ),
            const SizedBox(height: 18),
            _adRewardCard(),
            const SizedBox(height: 22),
            _sectionLabel('아이템'),
            for (final item in kMascotItems) _itemTile(item),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _adRewardCard() {
    final disabled = _adUsed >= _adMax;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFAF0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade100),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.ondemand_video,
                    size: 16, color: Colors.amber.shade800),
              ),
              const SizedBox(width: 10),
              const Text(
                '광고 보상',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
            height: 42,
            child: ElevatedButton(
              onPressed: disabled ? null : _watchAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.amber.shade100,
                disabledForegroundColor: Colors.amber.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                disabled ? '오늘 광고 보상 다 받았어요' : '광고 보고 +1 RP 받기',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // 아이콘 + 잠금/해금 상태 표시
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: unlocked
                      ? Colors.deepPurple.shade50
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(item.icon,
                        style: TextStyle(
                          fontSize: 26,
                          color: unlocked ? null : Colors.grey,
                        )),
                    if (!unlocked)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.lock,
                              size: 12, color: Colors.grey.shade600),
                        ),
                      ),
                  ],
                ),
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
                    Row(
                      children: [
                        Icon(Icons.bolt,
                            size: 12, color: Colors.deepPurple.shade300),
                        const SizedBox(width: 2),
                        Text('${item.cost} RP',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            )),
                        if (equipped) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('착용 중',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
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
                              ? Colors.deepPurple.shade50
                              : Colors.deepPurple,
                          foregroundColor: equipped
                              ? Colors.deepPurple
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(equipped ? '해제' : '착용'),
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
