import 'package:flutter_test/flutter_test.dart';
import 'package:dayrescue/models/rescue_record.dart';

void main() {
  group('RescueRecord JSON 직렬화', () {
    final record = RescueRecord(
      dateTime: DateTime(2026, 6, 29, 10, 30),
      isSuccess: true,
      earnedRp: 15,
      rescueRate: 75,
      savedCount: 3,
      minimumCount: 1,
      droppedCount: 2,
      failedCount: 0,
    );

    test('toJson / fromJson 왕복 변환', () {
      final json = record.toJson();
      final restored = RescueRecord.fromJson(json);

      expect(restored.rescueRate, 75);
      expect(restored.isSuccess, true);
      expect(restored.earnedRp, 15);
      expect(restored.savedCount, 3);
      expect(restored.minimumCount, 1);
      expect(restored.droppedCount, 2);
      expect(restored.failedCount, 0);
    });

    test('completedCount / totalCount 계산', () {
      expect(record.completedCount, 4); // savedCount + minimumCount
      expect(record.totalCount, 6); // 3+1+2+0
    });

    test('리스트 JSON 문자열 직렬화/역직렬화', () {
      final list = [record, record];
      final raw = RescueRecord.listToJsonString(list);
      final restored = RescueRecord.listFromJsonString(raw);

      expect(restored.length, 2);
      expect(restored.first.rescueRate, 75);
    });

    test('빈 문자열이면 빈 리스트 반환', () {
      expect(RescueRecord.listFromJsonString(''), isEmpty);
    });

    test('손상된 JSON이면 빈 리스트 반환', () {
      expect(RescueRecord.listFromJsonString('not-json'), isEmpty);
    });
  });
}
