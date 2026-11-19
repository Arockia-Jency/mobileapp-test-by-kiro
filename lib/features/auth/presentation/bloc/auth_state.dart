import 'package:equatable/equatable.dart';
import 'package:mobile_test_ai/features/auth/domain/entities/employee.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class Unauthenticated extends AuthState {
  const Unauthenticated();

  @override
  List<Object?> get props => [];
}

class AuthenticatingInProgress extends AuthState {
  const AuthenticatingInProgress();

  @override
  List<Object?> get props => [];
}

class Authenticated extends AuthState {
  final Employee employee;

  const Authenticated(this.employee);

  @override
  List<Object?> get props => [employee];
}

class AuthenticationFailed extends AuthState {
  final String message;

  const AuthenticationFailed(this.message);

  @override
  List<Object?> get props => [message];
}
