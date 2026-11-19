import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_test_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_test_ai/features/auth/domain/usecases/login_usecase.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;

  AuthBloc(this._loginUseCase) : super(const Unauthenticated()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    // Guard: no-op if already authenticated
    if (state is Authenticated) return;

    emit(const AuthenticatingInProgress());
    try {
      final employee = await _loginUseCase(event.email, event.password);
      emit(Authenticated(employee));
    } on AuthException {
      emit(const AuthenticationFailed('Invalid email or password. Please try again.'));
    } catch (_) {
      emit(const AuthenticationFailed('An unexpected error occurred. Please try again.'));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    emit(const Unauthenticated());
  }
}
