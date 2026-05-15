import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// DayRescue의 모든 영구 저장은 이 파일을 통해서만 한다.
// - SharedPreferences 인스턴스는 싱글톤으로 캐시한다.
// - 누적 RP는 단 하나의 키(dayrescue_total_rp)만 사용한다.
// - clear()/remove()로 RP를 지우지 않는다. 기본값 0은 키가 없을 때만 사용.
// - 웹에서는 origin(host+port)별로 localStorage가 분리되므로
//   항상 같은 포트로 실행해야 한다. → flutter run -d chrome --web-port 5001 권장.

class StorageService {
  // ===== 현행 키 =====
  static const _kTotalRp = 'dayrescue_total_rp';
  static const _kRecentEarnedRp = 'dayrescue_recent_earned_rp';
  static const _kRecentRescueRate = 'dayrescue_recent_rescue_rate';
  static const _kRecentResult = 'dayrescue_recent_result';
  static const _kUnlocked = 'dayrescue_unlocked_items';
  static const _kEquipped = 'dayrescue_equipped_items';
  static const _kAdRewardCount = 'dayrescue_ad_reward_count';
  static const _kAdRewardDate = 'dayrescue_ad_reward_date';
  static const _kMigratedV1 = 'dayrescue_migrated_v1';

  // ===== 이전 키 (v2까지 사용). 한 번만 옮겨옴 =====
  static const _oldKeys = <String, String>{
    'total_rp': _kTotalRp,
    'recent_earned_rp': _kRecentEarnedRp,
    'recent_rescue_rate': _kRecentRescueRate,
    'recent_result': _kRecentResult,
    'unlocked_items': _kUnlocked,
    'equipped_items': _kEquipped,
    'ad_reward_count': _kAdRewardCount,
    'ad_reward_date': _kAdRewardDate,
  };

  // SharedPreferences 인스턴스 캐시. 같은 Future를 공유한다.
  static Future<SharedPreferences>? _prefsFuture;
  // 마이그레이션 Future도 공유해서 동시 호출 시 중복 실행을 막는다.
  static Future<void>? _migrationFuture;

  static Future<SharedPreferences> _prefs() async {
    final p = await (_prefsFuture ??= SharedPreferences.getInstance());
    await (_migrationFuture ??= _migrate(p));
    return p;
  }

  // 앱이 시작될 때 한 번 호출해서 prefs를 미리 로드해두는 용도 (main에서 사용).
  static Future<void> warmUp() async {
    await _prefs();
  }

  // 이전 키 → 새 키로 한 번만 옮긴다. 기존 RP가 있던 사용자도 유지되게.
  static Future<void> _migrate(SharedPreferences p) async {
    if (p.getBool(_kMigratedV1) == true) {
      debugPrint('[Storage] Migration already done');
      return;
    }
    int movedCount = 0;
    for (final entry in _oldKeys.entries) {
      final oldKey = entry.key;
      final newKey = entry.value;
      if (!p.containsKey(oldKey)) continue;
      if (p.containsKey(newKey)) continue; // 새 키가 이미 있으면 건드리지 않음

      // 타입에 따라 옮긴다 (int / String / bool 중 하나)
      final intVal = p.getInt(oldKey);
      if (intVal != null) {
        await p.setInt(newKey, intVal);
        movedCount++;
        continue;
      }
      final strVal = p.getString(oldKey);
      if (strVal != null) {
        await p.setString(newKey, strVal);
        movedCount++;
        continue;
      }
    }
    await p.setBool(_kMigratedV1, true);
    debugPrint('[Storage] Migrated $movedCount old keys to dayrescue_* prefix');
  }

  // ===== 누적 RP (단일 출처) =====

  Future<int> getTotalRp() async {
    final p = await _prefs();
    final v = p.getInt(_kTotalRp) ?? 0;
    debugPrint('[Storage] Loaded total RP: $v');
    return v;
  }

  Future<void> saveTotalRp(int value) async {
    final p = await _prefs();
    final ok = await p.setInt(_kTotalRp, value);
    debugPrint('[Storage] Saved total RP: $value (ok=$ok)');
  }

  // 누적 RP에 amount만큼 더한다 (음수도 허용). 새 합계를 반환.
  Future<int> addRp(int amount) async {
    final cur = await getTotalRp();
    final next = cur + amount;
    await saveTotalRp(next);
    debugPrint('[Storage] addRp($amount) → $cur → $next');
    return next;
  }

  // 누적 RP에서 amount만큼 차감한다 (0 이하로 내려가지 않음). 새 합계를 반환.
  Future<int> spendRp(int amount) async {
    if (amount < 0) amount = 0;
    final cur = await getTotalRp();
    final next = (cur - amount).clamp(0, 0x7FFFFFFF);
    await saveTotalRp(next);
    debugPrint('[Storage] spendRp($amount) → $cur → $next');
    return next;
  }

  // ===== 최근 결과 =====
  // 결과 화면에서 한 번에 저장. 누적 RP는 addRp로 별도 호출.

  Future<void> saveRecentResult({
    required int earnedRp,
    required int rescueRate,
  }) async {
    final p = await _prefs();
    await p.setInt(_kRecentEarnedRp, earnedRp);
    await p.setInt(_kRecentRescueRate, rescueRate);
    await p.setString(
        _kRecentResult, '+$earnedRp RP · 구조율 $rescueRate%');
    debugPrint(
        '[Storage] Saved recent result: earned=$earnedRp rate=$rescueRate%');
  }

  Future<int> getRecentEarnedRp() async {
    final p = await _prefs();
    final v = p.getInt(_kRecentEarnedRp) ?? 0;
    debugPrint('[Storage] Loaded recent earned RP: $v');
    return v;
  }

  Future<int> getRecentRescueRate() async {
    final p = await _prefs();
    final v = p.getInt(_kRecentRescueRate) ?? 0;
    debugPrint('[Storage] Loaded recent rescue rate: $v');
    return v;
  }

  Future<String> getRecentResult() async {
    final p = await _prefs();
    return p.getString(_kRecentResult) ?? '';
  }

  Future<bool> hasAnyResult() async {
    final p = await _prefs();
    return p.containsKey(_kRecentResult);
  }

  // ===== 아이템 해금 / 착용 =====

  Future<List<String>> getUnlocked() async {
    final p = await _prefs();
    final raw = p.getString(_kUnlocked) ?? '';
    if (raw.isEmpty) return [];
    return raw.split(',');
  }

  Future<void> setUnlocked(List<String> ids) async {
    final p = await _prefs();
    await p.setString(_kUnlocked, ids.join(','));
  }

  Future<List<String>> getEquipped() async {
    final p = await _prefs();
    final raw = p.getString(_kEquipped) ?? '';
    if (raw.isEmpty) return [];
    return raw.split(',');
  }

  Future<void> setEquipped(List<String> ids) async {
    final p = await _prefs();
    await p.setString(_kEquipped, ids.join(','));
  }

  // ===== 광고 보상 (날짜 바뀌면 자동 0으로 리셋) =====

  Future<int> getAdRewardCount() async {
    final p = await _prefs();
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
    final p = await _prefs();
    final cur = await getAdRewardCount();
    await p.setInt(_kAdRewardCount, cur + 1);
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
