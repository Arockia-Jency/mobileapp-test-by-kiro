import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_test_ai/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_event.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUseCase _getCustomers;

  CustomerBloc(this._getCustomers) : super(const CustomerInitial()) {
    on<CustomerLoadRequested>(_onLoad);
    on<CustomerSearchChanged>(_onSearch);
  }

  Future<void> _onLoad(
    CustomerLoadRequested event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    try {
      final customers = await _getCustomers();
      emit(CustomerLoaded(
        allCustomers: customers,
        displayedCustomers: customers,
        searchQuery: '',
      ));
    } catch (e, st) {
      debugPrint('CustomerBloc error: $e\n$st');
      emit(const CustomerError('Could not load customers. Please try again.'));
    }
  }

  void _onSearch(CustomerSearchChanged event, Emitter<CustomerState> emit) {
    final current = state;
    if (current is! CustomerLoaded) return;

    final query = event.query.trim().toLowerCase();
    final displayed = query.isEmpty
        ? current.allCustomers
        : current.allCustomers.where((c) {
            return c.fullName.toLowerCase().contains(query) ||
                c.companyName.toLowerCase().contains(query);
          }).toList();

    emit(CustomerLoaded(
      allCustomers: current.allCustomers,
      displayedCustomers: displayed,
      searchQuery: event.query,
    ));
  }
}
