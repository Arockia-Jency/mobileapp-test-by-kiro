import 'package:equatable/equatable.dart';
import 'package:mobile_test_ai/features/customer/domain/entities/customer.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();
}

class CustomerInitial extends CustomerState {
  const CustomerInitial();

  @override
  List<Object?> get props => [];
}

class CustomerLoading extends CustomerState {
  const CustomerLoading();

  @override
  List<Object?> get props => [];
}

class CustomerLoaded extends CustomerState {
  final List<Customer> allCustomers;
  final List<Customer> displayedCustomers;
  final String searchQuery;

  const CustomerLoaded({
    required this.allCustomers,
    required this.displayedCustomers,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [allCustomers, displayedCustomers, searchQuery];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
