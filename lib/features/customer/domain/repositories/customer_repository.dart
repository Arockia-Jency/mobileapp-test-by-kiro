import 'package:mobile_test_ai/features/customer/domain/entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAllCustomers();
  Future<Customer?> getCustomerById(String id);
}
