import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences 래퍼. 키를 한 곳에서 관리한다.
// Chrome(웹)에서도 동작하며, 브라우저 IndexedDB/localStorage에 저장된다.

class StorageService {
  static const _kTotalRp = 'total_rp';
  static const _kUnlocked = 'unlocked_items'; // 쉼표로 join 저장
  static const _kEquipped = 'equipped_items'; // 쉼표로 join 저장
  static const _kAdRewardCount = 'ad_reward_count';
  static const _kAdRewardDate = 'ad_reward_date';
  static const _kRecentRescueRate = 'recent_rescue_rate';
  static const _kRecentResult = 'recent_result';

  Future<int> getTotalRp() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kTotalRp) ?? 0;
  }

  Future<void> addRp(int delta) async {
    final p = await SharedPreferences.getInstance();
    final cur = p.getInt(_kTotalRp) ?? 0;
    await p.setInt(_kTotalRp, cur + delta);
  }

  Future<List<String>> getUnlocked() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kUnlocked) ?? '';
    if (raw.isEmpty) return [];
    return raw.split(',');
  }

  Future<void> setUnlocked(List<String> ids) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUnlocked, ids.join(','));
  }

  Future<List<String>> getEquipped() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kEquipped) ?? '';
    if (raw.isEmpty) return [];
    return raw.split(',');
  }

  Future<void> setEquipped(List<String> ids) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kEquipped, ids.join(','));
  }

  // 광고 보상 횟수: 날짜가 바뀌면 0으로 리셋
  Future<int> getAdRewardCount() async {
    final p = await SharedPreferences.getInstance();
    final savedDate = p.getString(_kAdRewardDate);
    final today = _todayString();
    if (savedDate != today) {
      await p.setString(_kAdRewardDate, today);
      await p.setInt(_kAdRewardCount, 0);
      return 0;
    }
    return p.getInt(_kAdRewardCount) ?? 0;
  }

  Future<void> incrementAdRewardCount() async {
    final p = await SharedPreferences.getInstance();
    final cur = await getAdRewardCount();
    await p.setInt(_kAdRewardCount, cur + 1);
  }

  Future<void> setRecentRescueRate(int rate) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kRecentRescueRate, rate);
  }

  Future<int> getRecentRescueRate() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kRecentRescueRate) ?? 0;
  }

  Future<void> setRecentResult(String summary) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kRecentResult, summary);
  }

  Future<String> getRecentResult() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kRecentResult) ?? '';
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
