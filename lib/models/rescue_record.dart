import 'dart:convert';

class RescueRecord {
  final DateTime dateTime;
  final bool isSuccess;
  final int earnedRp;
  final int rescueRate;
  final int savedCount;
  final int minimumCount;
  final int droppedCount;
  final int failedCount;

  const RescueRecord({
    required this.dateTime,
    required this.isSuccess,
    required this.earnedRp,
    required this.rescueRate,
    required this.savedCount,
    required this.minimumCount,
    required this.droppedCount,
    required this.failedCount,
  });

  int get completedCount => savedCount + minimumCount;
  int get totalCount => savedCount + minimumCount + droppedCount + failedCount;
  String get successCriterionText => '구조율 50% 이상';

  Map<String, dynamic> toJson() => {
        'dateTime': dateTime.toIso8601String(),
        'isSuccess': isSuccess,
        'earnedRp': earnedRp,
        'rescueRate': rescueRate,
        'savedCount': savedCount,
        'minimumCount': minimumCount,
        'droppedCount': droppedCount,
        'failedCount': failedCount,
      };

  factory RescueRecord.fromJson(Map<String, dynamic> json) => RescueRecord(
        dateTime: DateTime.parse(json['dateTime'] as String),
        isSuccess: json['isSuccess'] as bool,
        earnedRp: json['earnedRp'] as int,
        rescueRate: json['rescueRate'] as int,
        savedCount: json['savedCount'] as int,
        minimumCount: json['minimumCount'] as int,
        droppedCount: json['droppedCount'] as int,
        failedCount: json['failedCount'] as int,
      );

  static RescueRecord? tryFromJson(Map<String, dynamic> json) {
    try {
      return RescueRecord.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  static List<RescueRecord> listFromJsonString(String raw) {
    if (raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(RescueRecord.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String listToJsonString(List<RescueRecord> records) =>
      jsonEncode(records.map((r) => r.toJson()).toList());
}
