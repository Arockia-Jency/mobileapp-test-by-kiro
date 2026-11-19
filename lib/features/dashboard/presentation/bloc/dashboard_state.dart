import 'package:equatable/equatable.dart';
import 'package:mobile_test_ai/features/dashboard/domain/entities/dashboard_summary.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();

  @override
  List<Object?> get props => [];
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();

  @override
  List<Object?> get props => [];
}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;

  const DashboardLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
