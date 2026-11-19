import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_test_ai/features/check_in/domain/entities/check_in_record.dart';
import 'package:mobile_test_ai/features/check_in/domain/usecases/check_in_usecase.dart';
import 'package:mobile_test_ai/features/check_in/domain/usecases/check_out_usecase.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_bloc.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_event.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_state.dart';

class MockCheckInUseCase extends Mock implements CheckInUseCase {}
class MockCheckOutUseCase extends Mock implements CheckOutUseCase {}

void main() {
  late MockCheckInUseCase mockCheckIn;
  late MockCheckOutUseCase mockCheckOut;

  final testRecord = CheckInRecord(checkInTime: DateTime(2024, 1, 15, 9, 0));
  final testRecordWithCheckout = CheckInRecord(
    checkInTime: DateTime(2024, 1, 15, 9, 0),
    checkOutTime: DateTime(2024, 1, 15, 17, 0),
  );

  setUp(() {
    mockCheckIn = MockCheckInUseCase();
    mockCheckOut = MockCheckOutUseCase();
    registerFallbackValue(testRecord);
  });

  test('initial state is NotCheckedIn', () {
    final bloc = CheckInBloc(mockCheckIn, mockCheckOut);
    expect(bloc.state, isA<NotCheckedIn>());
    bloc.close();
  });

  blocTest<CheckInBloc, CheckInState>(
    'emits [CheckedIn] when CheckInRequested from NotCheckedIn',
    build: () {
      when(() => mockCheckIn()).thenAnswer((_) async => testRecord);
      return CheckInBloc(mockCheckIn, mockCheckOut);
    },
    act: (bloc) => bloc.add(const CheckInRequested()),
    expect: () => [isA<CheckedIn>()],
  );

  blocTest<CheckInBloc, CheckInState>(
    'emits [CheckedOut] when CheckOutRequested from CheckedIn',
    build: () {
      when(() => mockCheckOut(any())).thenAnswer((_) async => testRecordWithCheckout);
      return CheckInBloc(mockCheckIn, mockCheckOut);
    },
    seed: () => CheckedIn(testRecord),
    act: (bloc) => bloc.add(const CheckOutRequested()),
    expect: () => [isA<CheckedOut>()],
  );

  blocTest<CheckInBloc, CheckInState>(
    'emits [CheckInError, NotCheckedIn] when CheckOutRequested before checking in',
    build: () => CheckInBloc(mockCheckIn, mockCheckOut),
    act: (bloc) => bloc.add(const CheckOutRequested()),
    expect: () => [isA<CheckInError>(), isA<NotCheckedIn>()],
  );

  blocTest<CheckInBloc, CheckInState>(
    // Property 1: idempotence - CheckInRequested when already CheckedOut is no-op
    'is a no-op when CheckInRequested while already CheckedOut',
    build: () => CheckInBloc(mockCheckIn, mockCheckOut),
    seed: () => CheckedOut(testRecordWithCheckout),
    act: (bloc) => bloc.add(const CheckInRequested()),
    expect: () => [],
  );
}
