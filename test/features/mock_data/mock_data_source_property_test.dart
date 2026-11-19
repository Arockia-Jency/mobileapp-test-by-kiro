// Feature: mobile-test-ai-poc, Property 2: Session isolation
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_test_ai/features/mock_data/mock_data_source.dart';
import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/check_in/domain/entities/check_in_record.dart';

void main() {
  for (var i = 0; i < 100; i++) {
    test('session isolation: resetSession restores initial state (iteration $i)', () {
      final source = MockDataSource.instance;

      // Simulate session activity
      source.todayCheckIn = CheckInRecord(checkInTime: DateTime.now());
      source.activities.add(Activity(
        id: 'extra_$i',
        customerId: 'cust_001',
        customerName: 'Test',
        title: 'Session activity $i',
        dueDate: DateTime.now(),
        status: ActivityStatus.pending,
      ));
      source.simulateError = true;

      // Reset simulates a new app launch
      source.resetSession();

      // No session data remains
      expect(source.todayCheckIn, isNull,
          reason: 'todayCheckIn should be null after reset');
      expect(source.simulateError, isFalse,
          reason: 'simulateError should be false after reset');
      expect(
        source.activities.any((a) => a.id == 'extra_$i'),
        isFalse,
        reason: 'Session-added activity should not persist after reset',
      );
    });
  }
}
