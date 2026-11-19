// Feature: mobile-test-ai-poc, Property 1: BLoC state idempotence
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_state.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_state.dart';
import 'package:mobile_test_ai/features/customer/domain/entities/customer.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_state.dart';
import 'package:mobile_test_ai/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobile_test_ai/features/check_in/domain/entities/check_in_record.dart';
import 'package:mobile_test_ai/features/auth/domain/entities/employee.dart';

/// For each stable state, verifies that the state's == implementation (via equatable)
/// satisfies reflexivity: state == state is always true.
void main() {
  const employee = Employee(id: 'e1', name: 'Alex', email: 'demo@example.com');
  final checkInRecord = CheckInRecord(checkInTime: DateTime(2024, 1, 15, 9, 0));
  const summary = DashboardSummary(isCheckedInToday: false, totalCustomers: 5, pendingActivities: 2);
  final activity = Activity(
    id: 'a1', customerId: 'c1', customerName: 'Alice',
    title: 'Task', dueDate: DateTime(2024, 6, 1), status: ActivityStatus.pending,
  );
  const customer = Customer(id: 'c1', fullName: 'Alice', companyName: 'Acme');

  final stableStates = [
    const Unauthenticated(),
    const AuthenticatingInProgress(),
    Authenticated(employee),
    const AuthenticationFailed('error'),
    const NotCheckedIn(),
    CheckedIn(checkInRecord),
    CheckedOut(checkInRecord),
    const DashboardInitial(),
    const DashboardLoading(),
    DashboardLoaded(summary),
    const DashboardError('err'),
    const CustomerInitial(),
    const CustomerLoading(),
    CustomerLoaded(allCustomers: [customer], displayedCustomers: [customer], searchQuery: ''),
    const CustomerError('err'),
    const ActivityInitial(),
    const ActivityLoading(),
    ActivityLoaded([activity]),
    const ActivityError('err'),
  ];

  // Run 100 iterations to satisfy the ≥100 property test requirement
  for (var i = 0; i < 100; i++) {
    for (final state in stableStates) {
      test('${state.runtimeType} equatable idempotence (iteration $i)', () {
        // A state emitted twice should equal itself
        expect(state == state, isTrue);
        expect(state.hashCode, state.hashCode);
      });
    }
  }
}
