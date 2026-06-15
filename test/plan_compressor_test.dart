import 'package:flutter_test/flutter_test.dart';
import 'package:dayrescue/models/compressed_task.dart';
import 'package:dayrescue/models/task_item.dart';
import 'package:dayrescue/services/plan_compressor.dart';

void main() {
  group('PlanCompressor', () {
    test('must-save task becomes core and appears first', () {
      final compressor = PlanCompressor();

      final result = compressor.compress(
        tasks: [
          TaskItem(
            name: '공부',
            deadline: Deadline.today,
            loss: Loss.medium,
            estimatedMinutes: 30,
          ),
          TaskItem(
            name: '운동',
            deadline: Deadline.today,
            loss: Loss.medium,
            estimatedMinutes: 30,
          ),
          TaskItem(
            name: '영어',
            deadline: Deadline.today,
            loss: Loss.medium,
            estimatedMinutes: 30,
          ),
        ],
        fixedSchedule: '',
        freeTime: '19:00~23:00',
        condition: 50,
        mustDo: '공부',
      );

      final study = result.tasks.firstWhere((task) => task.name == '공부');

      expect(study.processType, ProcessType.core);
      expect(study.priority, 1);
      expect(result.successCriteria.contains('공부'), isTrue);
    });

    test('low condition reduces optional tasks', () {
      final compressor = PlanCompressor();

      final result = compressor.compress(
        tasks: [
          TaskItem(
            name: '공부',
            deadline: Deadline.today,
            loss: Loss.medium,
            estimatedMinutes: 30,
          ),
          TaskItem(
            name: '운동',
            deadline: Deadline.none,
            loss: Loss.small,
            estimatedMinutes: 30,
          ),
          TaskItem(
            name: '영어',
            deadline: Deadline.none,
            loss: Loss.small,
            estimatedMinutes: 30,
          ),
          TaskItem(
            name: '청소',
            deadline: Deadline.none,
            loss: Loss.small,
            estimatedMinutes: 30,
          ),
        ],
        fixedSchedule: '',
        freeTime: '20:00~23:00',
        condition: 25,
        mustDo: '공부',
      );

      final study = result.tasks.firstWhere((task) => task.name == '공부');
      final workout = result.tasks.firstWhere((task) => task.name == '운동');
      final english = result.tasks.firstWhere((task) => task.name == '영어');
      final cleaning = result.tasks.firstWhere((task) => task.name == '청소');

      expect(study.processType, ProcessType.core);
      expect(
        [ProcessType.minimum, ProcessType.exclude],
        contains(workout.processType),
      );
      expect(
        [ProcessType.minimum, ProcessType.exclude],
        contains(english.processType),
      );
      expect(cleaning.processType, ProcessType.exclude);
    });

    test('urgent large-loss task becomes core', () {
      final compressor = PlanCompressor();

      final result = compressor.compress(
        tasks: [
          TaskItem(
            name: '과제',
            deadline: Deadline.today,
            loss: Loss.large,
            estimatedMinutes: 60,
          ),
          TaskItem(
            name: '운동',
            deadline: Deadline.none,
            loss: Loss.small,
            estimatedMinutes: 30,
          ),
          TaskItem(
            name: '휴식',
            deadline: Deadline.none,
            loss: Loss.small,
            estimatedMinutes: 30,
          ),
        ],
        fixedSchedule: '',
        freeTime: '19:00~22:00',
        condition: 40,
        mustDo: '과제',
      );

      final assignment = result.tasks.firstWhere((task) => task.name == '과제');

      expect(assignment.processType, ProcessType.core);
      expect(assignment.durationMinutes, lessThanOrEqualTo(60));
      expect(result.successCriteria.contains('과제'), isTrue);
    });

    test('fixed schedule is added as mandatory task', () {
      final compressor = PlanCompressor();

      final result = compressor.compress(
        tasks: [
          TaskItem(
            name: '공부',
            deadline: Deadline.today,
            loss: Loss.medium,
            estimatedMinutes: 30,
          ),
        ],
        fixedSchedule: '일 08:00~18:00',
        freeTime: '19:00~23:00',
        condition: 50,
        mustDo: '공부',
      );

      final fixed = result.tasks.first;

      expect(fixed.processType, ProcessType.mandatory);
      expect(fixed.name, '일 08:00~18:00');
      expect(fixed.priority, 1);
    });

    test('time blocks are generated from free time start', () {
      final compressor = PlanCompressor();

      final result = compressor.compress(
        tasks: [
          TaskItem(
            name: '공부',
            deadline: Deadline.today,
            loss: Loss.medium,
            estimatedMinutes: 30,
          ),
          TaskItem(
            name: '운동',
            deadline: Deadline.today,
            loss: Loss.medium,
            estimatedMinutes: 30,
          ),
        ],
        fixedSchedule: '',
        freeTime: '19:00~23:00',
        condition: 60,
        mustDo: '공부',
      );

      expect(result.timeBlocks, isNotEmpty);
      expect(result.timeBlocks.first.startsWith('19:00'), isTrue);
    });
  });
}
