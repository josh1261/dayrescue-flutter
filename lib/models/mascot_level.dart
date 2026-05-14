// 누적 RP → 레벨/호칭 매핑.
// Lv.1: 0~49 / Lv.2: 50~149 / Lv.3: 150~299 / Lv.4: 300~499 / Lv.5: 500+

class MascotLevel {
  final int level;
  final String title;
  final int currentRp;
  final int currentLevelStart; // 이번 레벨 시작 RP
  final int nextLevelStart; // 다음 레벨 시작 RP (만렙이면 currentLevelStart)
  final bool isMax;

  MascotLevel({
    required this.level,
    required this.title,
    required this.currentRp,
    required this.currentLevelStart,
    required this.nextLevelStart,
    required this.isMax,
  });

  // 이번 레벨 내 진행도 (0.0 ~ 1.0)
  double get progress {
    if (isMax) return 1.0;
    final span = nextLevelStart - currentLevelStart;
    if (span <= 0) return 1.0;
    final cur = currentRp - currentLevelStart;
    return (cur / span).clamp(0.0, 1.0);
  }

  // 다음 레벨까지 남은 RP
  int get rpToNext => isMax ? 0 : (nextLevelStart - currentRp);

  factory MascotLevel.fromRp(int rp) {
    if (rp >= 500) {
      return MascotLevel(
        level: 5,
        title: '마스터 구조대장',
        currentRp: rp,
        currentLevelStart: 500,
        nextLevelStart: 500,
        isMax: true,
      );
    }
    if (rp >= 300) {
      return MascotLevel(
        level: 4,
        title: '집중 구조대장',
        currentRp: rp,
        currentLevelStart: 300,
        nextLevelStart: 500,
        isMax: false,
      );
    }
    if (rp >= 150) {
      return MascotLevel(
        level: 3,
        title: '하루 구조대원',
        currentRp: rp,
        currentLevelStart: 150,
        nextLevelStart: 300,
        isMax: false,
      );
    }
    if (rp >= 50) {
      return MascotLevel(
        level: 2,
        title: '계획 구조 고양이',
        currentRp: rp,
        currentLevelStart: 50,
        nextLevelStart: 150,
        isMax: false,
      );
    }
    return MascotLevel(
      level: 1,
      title: '초보 구조 고양이',
      currentRp: rp,
      currentLevelStart: 0,
      nextLevelStart: 50,
      isMax: false,
    );
  }
}
