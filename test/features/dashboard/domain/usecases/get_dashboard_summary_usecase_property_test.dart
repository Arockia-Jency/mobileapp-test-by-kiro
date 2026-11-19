// Feature: mobile-test-ai-poc, Property 6: Dashboard summary count derivation
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/mock_data/mock_data_source.dart';
import 'package:mobile_test_ai/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:mobile_test_ai/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';

void main() {
  setUp(() => MockDataSource.instance.resetSession());

  for (var i = 0; i < 100; i++) {
    test('dashboard counts derive correctly from data source (iteration $i)', () async {
      final source = MockDataSource.instance;

      // Seed N activities: i pending, 2 done
      final today = DateTime.now();
      final pendingCount = i % 10;
      source.activities = List.generate(pendingCount, (j) => Activity(
        id: 'p_$j',
        customerId: 'cust_001',
        customerName: 'Test',
        title: 'Pending $j',
        dueDate: today,
        status: ActivityStatus.pending,
      )) + [
        Activity(
          id: 'done_1',
          customerId: 'cust_001',
          customerName: 'Test',
          title: 'Done',
          dueDate: today,
          status: ActivityStatus.done,
        ),
      ];

      final repo = DashboardRepositoryImpl(source);
      final useCase = GetDashboardSummaryUseCase(repo);
      final summary = await useCase();

      // totalCustomers == customers.length
      expect(summary.totalCustomers, source.customers.length);

      // pendingActivities == count of activities with status pending AND dueDate <= today
      final expectedPending = source.activities.where((a) {
        final d = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
        final t = DateTime(today.year, today.month, today.day);
        return a.status == ActivityStatus.pending && !d.isAfter(t);
      }).length;
      expect(summary.pendingActivities, expectedPending);
    });
  }
}
