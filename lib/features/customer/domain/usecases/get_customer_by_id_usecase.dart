import 'package:mobile_test_ai/features/customer/domain/entities/customer.dart';
import 'package:mobile_test_ai/features/customer/domain/repositories/customer_repository.dart';

class GetCustomerByIdUseCase {
  final CustomerRepository _repository;

  const GetCustomerByIdUseCase(this._repository);

  Future<Customer?> call(String id) => _repository.getCustomerById(id);
}
