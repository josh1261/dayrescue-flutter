// 마스코트 꾸미기 아이템

class MascotItem {
  final String id;
  final String name;
  final int cost;
  final String icon; // 표시용 이모지

  const MascotItem({
    required this.id,
    required this.name,
    required this.cost,
    required this.icon,
  });
}

// 마스코트 상점 기본 아이템 목록
const List<MascotItem> kMascotItems = [
  MascotItem(id: 'hat', name: '작은 모자', cost: 30, icon: '🎩'),
  MascotItem(id: 'glasses', name: '동그란 안경', cost: 50, icon: '👓'),
  MascotItem(id: 'sunglasses', name: '선글라스', cost: 80, icon: '🕶️'),
  MascotItem(id: 'beep', name: '삑삑 효과음', cost: 100, icon: '🔔'),
  MascotItem(id: 'helmet', name: '구조대 헬멧', cost: 200, icon: '⛑️'),
];
