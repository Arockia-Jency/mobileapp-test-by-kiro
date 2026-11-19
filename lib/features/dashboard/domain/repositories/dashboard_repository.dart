import 'package:mobile_test_ai/features/dashboard/domain/entities/dashboard_summary.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> getSummary();
}
