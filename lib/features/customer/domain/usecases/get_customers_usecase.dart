import 'package:mobile_test_ai/features/customer/domain/entities/customer.dart';
import 'package:mobile_test_ai/features/customer/domain/repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository _repository;

  const GetCustomersUseCase(this._repository);

  Future<List<Customer>> call() => _repository.getAllCustomers();
}
