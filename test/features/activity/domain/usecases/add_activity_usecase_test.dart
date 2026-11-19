import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/activity/domain/repositories/activity_repository.dart';
import 'package:mobile_test_ai/features/activity/domain/usecases/add_activity_usecase.dart';
import 'package:mobile_test_ai/features/activity/domain/usecases/mark_activity_done_usecase.dart';

class MockActivityRepository extends Mock implements ActivityRepository {}

final _testActivity = Activity(
  id: 'act_test',
  customerId: 'cust_001',
  customerName: 'Alice',
  title: 'Follow up',
  dueDate: DateTime(2025, 6, 1),
  status: ActivityStatus.pending,
);

void main() {
  late MockActivityRepository mockRepo;

  setUp(() {
    mockRepo = MockActivityRepository();
    registerFallbackValue(_testActivity);
  });

  group('AddActivityUseCase', () {
    test('calls repository addActivity with the given activity', () async {
      when(() => mockRepo.addActivity(any())).thenAnswer((_) async {});

      final useCase = AddActivityUseCase(mockRepo);
      await useCase(_testActivity);

      verify(() => mockRepo.addActivity(_testActivity)).called(1);
    });

    test('propagates exception from repository', () {
      when(() => mockRepo.addActivity(any())).thenThrow(Exception('error'));

      final useCase = AddActivityUseCase(mockRepo);
      expect(() => useCase(_testActivity), throwsA(isA<Exception>()));
    });
  });

  group('MarkActivityDoneUseCase', () {
    test('returns updated activity with status done', () async {
      final done = _testActivity.copyWith(status: ActivityStatus.done);
      when(() => mockRepo.markDone(any())).thenAnswer((_) async => done);

      final useCase = MarkActivityDoneUseCase(mockRepo);
      final result = await useCase(_testActivity.id);

      expect(result.status, ActivityStatus.done);
    });

    test('propagates StateError when activity already done', () {
      when(() => mockRepo.markDone(any()))
          .thenThrow(StateError('Activity is already done.'));

      final useCase = MarkActivityDoneUseCase(mockRepo);
      expect(() => useCase(_testActivity.id), throwsStateError);
    });
  });
}
