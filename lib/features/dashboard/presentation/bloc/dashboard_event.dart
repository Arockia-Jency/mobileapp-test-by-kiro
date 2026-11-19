import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
}

class DashboardLoadRequested extends DashboardEvent {
  const DashboardLoadRequested();

  @override
  List<Object?> get props => [];
}

class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();

  @override
  List<Object?> get props => [];
}
