import 'package:mobile_test_ai/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:mobile_test_ai/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase {
  final DashboardRepository _repository;

  const GetDashboardSummaryUseCase(this._repository);

  Future<DashboardSummary> call() => _repository.getSummary();
}
