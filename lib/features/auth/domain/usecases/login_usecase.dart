import 'package:mobile_test_ai/features/auth/domain/entities/employee.dart';
import 'package:mobile_test_ai/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Employee> call(String email, String password) {
    return _repository.login(email: email, password: password);
  }
}
