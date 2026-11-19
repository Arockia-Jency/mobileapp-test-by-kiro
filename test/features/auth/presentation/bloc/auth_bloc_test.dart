import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_test_ai/features/auth/domain/entities/employee.dart';
import 'package:mobile_test_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_test_ai/features/auth/domain/usecases/login_usecase.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

const _testEmployee = Employee(id: 'emp_001', name: 'Alex Jordan', email: 'demo@example.com');

void main() {
  late MockLoginUseCase mockLoginUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
  });

  test('initial state is Unauthenticated', () {
    final bloc = AuthBloc(mockLoginUseCase);
    expect(bloc.state, isA<Unauthenticated>());
    bloc.close();
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthenticatingInProgress, Authenticated] on valid login',
    build: () {
      when(() => mockLoginUseCase(any(), any())).thenAnswer((_) async => _testEmployee);
      return AuthBloc(mockLoginUseCase);
    },
    act: (bloc) => bloc.add(
      const LoginSubmitted(email: 'demo@example.com', password: 'password123'),
    ),
    expect: () => [isA<AuthenticatingInProgress>(), isA<Authenticated>()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthenticatingInProgress, AuthenticationFailed] on invalid credentials',
    build: () {
      when(() => mockLoginUseCase(any(), any()))
          .thenThrow(const AuthException('invalid_credentials'));
      return AuthBloc(mockLoginUseCase);
    },
    act: (bloc) => bloc.add(
      const LoginSubmitted(email: 'bad@test.com', password: 'wrong'),
    ),
    expect: () => [isA<AuthenticatingInProgress>(), isA<AuthenticationFailed>()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [Unauthenticated] on LogoutRequested',
    build: () => AuthBloc(mockLoginUseCase),
    seed: () => Authenticated(_testEmployee),
    act: (bloc) => bloc.add(const LogoutRequested()),
    expect: () => [isA<Unauthenticated>()],
  );

  blocTest<AuthBloc, AuthState>(
    // Property 1: idempotence — logging out twice gives same final state
    'emits Unauthenticated when LogoutRequested is sent twice',
    build: () => AuthBloc(mockLoginUseCase),
    seed: () => Authenticated(_testEmployee),
    act: (bloc) {
      bloc.add(const LogoutRequested());
      bloc.add(const LogoutRequested());
    },
    expect: () => [isA<Unauthenticated>()],
  );
}
