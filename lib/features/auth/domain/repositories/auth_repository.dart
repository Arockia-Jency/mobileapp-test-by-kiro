import 'package:mobile_test_ai/features/auth/domain/entities/employee.dart';

class AuthException implements Exception {
  final String code;
  const AuthException(this.code);

  @override
  String toString() => 'AuthException($code)';
}

abstract class AuthRepository {
  /// Logs in with [email] and [password].
  /// Returns the authenticated [Employee] on success.
  /// Throws [AuthException('invalid_credentials')] on mismatch.
  Future<Employee> login({required String email, required String password});
}
