import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_test_ai/features/auth/domain/entities/employee.dart';
import 'package:mobile_test_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_test_ai/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const _testEmployee = Employee(id: 'emp_001', name: 'Alex Jordan', email: 'demo@example.com');

void main() {
  late MockAuthRepository mockRepo;
  late LoginUseCase useCase;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = LoginUseCase(mockRepo);
  });

  test('returns Employee on matching credentials', () async {
    when(() => mockRepo.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => _testEmployee);

    final result = await useCase('demo@example.com', 'password123');

    expect(result, _testEmployee);
  });

  test('propagates AuthException on invalid credentials', () async {
    when(() => mockRepo.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenThrow(const AuthException('invalid_credentials'));

    expect(
      () => useCase('bad@test.com', 'wrong'),
      throwsA(isA<AuthException>()),
    );
  });
}
