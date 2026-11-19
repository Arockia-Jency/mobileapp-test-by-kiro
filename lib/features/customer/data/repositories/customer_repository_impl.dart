import 'package:mobile_test_ai/features/customer/domain/entities/customer.dart';
import 'package:mobile_test_ai/features/customer/domain/repositories/customer_repository.dart';
import 'package:mobile_test_ai/features/mock_data/mock_data_source.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final MockDataSource _source;

  CustomerRepositoryImpl(this._source);

  @override
  Future<List<Customer>> getAllCustomers() async {
    return List.unmodifiable(_source.customers);
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    try {
      return _source.customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
