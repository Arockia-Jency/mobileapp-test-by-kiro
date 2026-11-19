import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:mobile_test_ai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:mobile_test_ai/features/mock_data/mock_data_source.dart';

class DataSourceException implements Exception {
  final String message;
  const DataSourceException(this.message);

  @override
  String toString() => 'DataSourceException($message)';
}

class DashboardRepositoryImpl implements DashboardRepository {
  final MockDataSource _source;

  DashboardRepositoryImpl(this._source);

  @override
  Future<DashboardSummary> getSummary() async {
    if (_source.simulateError) {
      throw const DataSourceException('simulated_error');
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final checkIn = _source.todayCheckIn;
    final isCheckedIn = checkIn != null;

    final pendingCount = _source.activities.where((a) {
      final dueDate = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
      return a.status == ActivityStatus.pending &&
          !dueDate.isAfter(todayDate);
    }).length;

    return DashboardSummary(
      isCheckedInToday: isCheckedIn,
      checkInTimeFormatted: isCheckedIn ? checkIn.checkInFormatted : null,
      totalCustomers: _source.customers.length,
      pendingActivities: pendingCount,
    );
  }
}
