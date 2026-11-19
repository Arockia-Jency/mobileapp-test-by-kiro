import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_test_ai/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummaryUseCase _getSummary;

  DashboardBloc(this._getSummary) : super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoad);
    on<DashboardRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(DashboardEvent event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoading());
    try {
      final summary = await _getSummary();
      emit(DashboardLoaded(summary));
    } catch (e, st) {
      debugPrint('DashboardBloc error: $e\n$st');
      emit(const DashboardError('Could not load dashboard data. Please try again.'));
    }
  }
}
