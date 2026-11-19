import 'package:mobile_test_ai/features/auth/domain/entities/employee.dart';
import 'package:mobile_test_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_test_ai/features/mock_data/mock_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final MockDataSource _source;

  AuthRepositoryImpl(this._source);

  @override
  Future<Employee> login({required String email, required String password}) async {
    if (email == _source.demoEmail && password == _source.demoPassword) {
      return _source.currentEmployee;
    }
    throw const AuthException('invalid_credentials');
  }
}
