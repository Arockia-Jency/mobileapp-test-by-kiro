import 'package:equatable/equatable.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
}

class CustomerLoadRequested extends CustomerEvent {
  const CustomerLoadRequested();

  @override
  List<Object?> get props => [];
}

class CustomerSearchChanged extends CustomerEvent {
  final String query;

  const CustomerSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
