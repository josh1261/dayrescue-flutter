// DayRescue 기본 빌드 확인용 스모크 테스트.
// 홈 화면이 떠서 앱 이름이 보이는지만 확인한다.

import 'package:flutter_test/flutter_test.dart';

import 'package:dayrescue/main.dart';

void main() {
  testWidgets('홈 화면에 앱 이름이 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const DayRescueApp());
    await tester.pump(); // SharedPreferences future 시작
    expect(find.text('DayRescue'), findsOneWidget);
    expect(find.text('오늘 계획 압축하기'), findsOneWidget);
  });
}
