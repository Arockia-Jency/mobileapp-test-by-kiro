import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_test_ai/features/check_in/domain/entities/check_in_record.dart';
import 'package:mobile_test_ai/features/check_in/domain/repositories/check_in_repository.dart';
import 'package:mobile_test_ai/features/check_in/domain/usecases/check_in_usecase.dart';
import 'package:mobile_test_ai/features/check_in/domain/usecases/check_out_usecase.dart';

class MockCheckInRepository extends Mock implements CheckInRepository {}

void main() {
  late MockCheckInRepository mockRepo;

  final record = CheckInRecord(checkInTime: DateTime(2024, 1, 15, 9, 0));

  setUpAll(() {
    registerFallbackValue(CheckInRecord(checkInTime: DateTime(2024)));
  });

  setUp(() {
    mockRepo = MockCheckInRepository();
  });

  group('CheckInUseCase', () {
    test('returns a CheckInRecord on success', () async {
      when(() => mockRepo.checkIn()).thenAnswer((_) async => record);

      final useCase = CheckInUseCase(mockRepo);
      final result = await useCase();

      expect(result, record);
      expect(result.checkOutTime, isNull);
    });

    test('propagates exception from repository', () {
      when(() => mockRepo.checkIn()).thenThrow(Exception('repo error'));
      final useCase = CheckInUseCase(mockRepo);
      expect(() => useCase(), throwsA(isA<Exception>()));
    });
  });

  group('CheckOutUseCase', () {
    test('returns updated CheckInRecord with checkOutTime set', () async {
      final record = CheckInRecord(checkInTime: DateTime(2024, 1, 15, 9, 0));
      final updated = record.copyWith(checkOutTime: DateTime(2024, 1, 15, 17, 0));
      when(() => mockRepo.checkOut(any())).thenAnswer((_) async => updated);

      final useCase = CheckOutUseCase(mockRepo);
      final result = await useCase(record);

      expect(result.checkOutTime, isNotNull);
    });

    test('propagates StateError when already checked out', () {
      final record = CheckInRecord(
        checkInTime: DateTime(2024, 1, 15, 9, 0),
        checkOutTime: DateTime(2024, 1, 15, 17, 0),
      );
      when(() => mockRepo.checkOut(any())).thenThrow(StateError('Already checked out.'));

      final useCase = CheckOutUseCase(mockRepo);
      expect(() => useCase(record), throwsStateError);
    });
  });
}
