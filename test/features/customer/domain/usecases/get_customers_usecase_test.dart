import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_test_ai/features/customer/domain/entities/customer.dart';
import 'package:mobile_test_ai/features/customer/domain/repositories/customer_repository.dart';
import 'package:mobile_test_ai/features/customer/domain/usecases/get_customers_usecase.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late MockCustomerRepository mockRepo;
  late GetCustomersUseCase useCase;

  final testCustomers = [
    const Customer(id: 'c1', fullName: 'Alice Smith', companyName: 'Acme'),
    const Customer(id: 'c2', fullName: 'Bob Jones', companyName: 'Beta Corp'),
  ];

  setUp(() {
    mockRepo = MockCustomerRepository();
    useCase = GetCustomersUseCase(mockRepo);
  });

  test('returns list of customers from repository', () async {
    when(() => mockRepo.getAllCustomers()).thenAnswer((_) async => testCustomers);

    final result = await useCase();

    expect(result, testCustomers);
    expect(result.length, 2);
  });

  test('returns empty list when no customers', () async {
    when(() => mockRepo.getAllCustomers()).thenAnswer((_) async => []);

    final result = await useCase();

    expect(result, isEmpty);
  });

  test('propagates exception from repository', () {
    when(() => mockRepo.getAllCustomers()).thenThrow(Exception('error'));
    expect(() => useCase(), throwsA(isA<Exception>()));
  });
}
