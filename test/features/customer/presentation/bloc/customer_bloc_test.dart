import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_test_ai/features/customer/domain/entities/customer.dart';
import 'package:mobile_test_ai/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_event.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_state.dart';

class MockGetCustomersUseCase extends Mock implements GetCustomersUseCase {}

final _customers = [
  const Customer(id: 'c1', fullName: 'Alice Smith', companyName: 'Acme Corp'),
  const Customer(id: 'c2', fullName: 'Bob Jones', companyName: 'Beta Inc'),
  const Customer(id: 'c3', fullName: 'Carol Adams', companyName: 'Acme Corp'),
];

void main() {
  late MockGetCustomersUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetCustomersUseCase();
  });

  test('initial state is CustomerInitial', () {
    final bloc = CustomerBloc(mockUseCase);
    expect(bloc.state, isA<CustomerInitial>());
    bloc.close();
  });

  blocTest<CustomerBloc, CustomerState>(
    'emits [CustomerLoading, CustomerLoaded] on successful load',
    build: () {
      when(() => mockUseCase()).thenAnswer((_) async => _customers);
      return CustomerBloc(mockUseCase);
    },
    act: (bloc) => bloc.add(const CustomerLoadRequested()),
    expect: () => [isA<CustomerLoading>(), isA<CustomerLoaded>()],
    verify: (bloc) {
      final state = bloc.state as CustomerLoaded;
      expect(state.allCustomers.length, 3);
      expect(state.displayedCustomers.length, 3);
    },
  );

  blocTest<CustomerBloc, CustomerState>(
    'filters customers by search query',
    build: () {
      when(() => mockUseCase()).thenAnswer((_) async => _customers);
      return CustomerBloc(mockUseCase);
    },
    seed: () => CustomerLoaded(
      allCustomers: _customers,
      displayedCustomers: _customers,
      searchQuery: '',
    ),
    act: (bloc) => bloc.add(const CustomerSearchChanged('acme')),
    expect: () => [
      isA<CustomerLoaded>().having(
        (s) => s.displayedCustomers.length,
        'filtered count',
        2, // Alice + Carol both at Acme Corp
      ),
    ],
  );

  blocTest<CustomerBloc, CustomerState>(
    'restores full list when search query is cleared',
    build: () {
      when(() => mockUseCase()).thenAnswer((_) async => _customers);
      return CustomerBloc(mockUseCase);
    },
    seed: () => CustomerLoaded(
      allCustomers: _customers,
      displayedCustomers: _customers.where((c) => c.companyName.contains('Acme')).toList(),
      searchQuery: 'acme',
    ),
    act: (bloc) => bloc.add(const CustomerSearchChanged('')),
    expect: () => [
      isA<CustomerLoaded>().having(
        (s) => s.displayedCustomers.length,
        'full list count',
        3,
      ),
    ],
  );

  blocTest<CustomerBloc, CustomerState>(
    'emits [CustomerLoading, CustomerError] when use case throws',
    build: () {
      when(() => mockUseCase()).thenThrow(Exception('error'));
      return CustomerBloc(mockUseCase);
    },
    act: (bloc) => bloc.add(const CustomerLoadRequested()),
    expect: () => [isA<CustomerLoading>(), isA<CustomerError>()],
  );
}
