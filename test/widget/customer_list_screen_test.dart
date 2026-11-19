import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_test_ai/features/customer/domain/entities/customer.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_event.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_state.dart';
import 'package:mobile_test_ai/features/customer/presentation/screens/customer_list_screen.dart';

class MockCustomerBloc extends MockBloc<CustomerEvent, CustomerState>
    implements CustomerBloc {}

final _customers = [
  const Customer(id: 'c1', fullName: 'Alice Smith', companyName: 'Acme Corp'),
  const Customer(id: 'c2', fullName: 'Bob Jones', companyName: 'Beta Inc'),
];

void main() {
  testWidgets('CustomerListScreen renders search field and customer items',
      (tester) async {
    final mockBloc = MockCustomerBloc();
    when(() => mockBloc.state).thenReturn(
      CustomerLoaded(
        allCustomers: _customers,
        displayedCustomers: _customers,
        searchQuery: '',
      ),
    );

    await tester.pumpWidget(
      BlocProvider<CustomerBloc>.value(
        value: mockBloc,
        child: const MaterialApp(home: CustomerListScreen()),
      ),
    );

    expect(find.byKey(const Key('customer_search')), findsOneWidget);
    expect(find.byKey(const Key('customer_item_c1')), findsOneWidget);
    expect(find.byKey(const Key('customer_item_c2')), findsOneWidget);
  });

  testWidgets('CustomerListScreen shows no-match message when filtered list is empty',
      (tester) async {
    final mockBloc = MockCustomerBloc();
    when(() => mockBloc.state).thenReturn(
      CustomerLoaded(
        allCustomers: _customers,
        displayedCustomers: const [],
        searchQuery: 'zzz',
      ),
    );

    await tester.pumpWidget(
      BlocProvider<CustomerBloc>.value(
        value: mockBloc,
        child: const MaterialApp(home: CustomerListScreen()),
      ),
    );

    expect(find.byKey(const Key('no_match_message')), findsOneWidget);
  });
}
