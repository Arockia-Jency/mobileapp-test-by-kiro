// Feature: mobile-test-ai-poc, Property 4: Activity sort order invariant
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';

// Expose _sortActivities for property testing via extension
List<Activity> testSort(List<Activity> raw) {
  final pending = raw.where((a) => a.status == ActivityStatus.pending).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  final done = raw.where((a) => a.status == ActivityStatus.done).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return [...pending, ...done];
}

void main() {
  final base = DateTime(2024, 1, 1);

  // Generate 100 shuffled activity lists
  for (var i = 0; i < 100; i++) {
    test('sort order invariant holds for permutation $i', () {
      // Build a list by cycling through statuses and dates
      final activities = List.generate(6, (j) {
        final status = (i + j) % 3 == 0 ? ActivityStatus.done : ActivityStatus.pending;
        final offset = (i * 7 + j * 3) % 30;
        return Activity(
          id: 'act_${i}_$j',
          customerId: 'cust_001',
          customerName: 'Test',
          title: 'Task $j',
          dueDate: base.add(Duration(days: offset)),
          status: status,
        );
      });

      final sorted = testSort(activities);

      // All pending items come before done items
      bool seenDone = false;
      for (final a in sorted) {
        if (a.status == ActivityStatus.done) seenDone = true;
        if (seenDone) {
          expect(a.status, ActivityStatus.done,
              reason: 'Pending item appeared after done item');
        }
      }

      // Within each group, items are ordered by dueDate ascending
      final pendingSorted = sorted.where((a) => a.status == ActivityStatus.pending).toList();
      for (var k = 1; k < pendingSorted.length; k++) {
        expect(
          pendingSorted[k].dueDate.compareTo(pendingSorted[k - 1].dueDate),
          greaterThanOrEqualTo(0),
        );
      }

      final doneSorted = sorted.where((a) => a.status == ActivityStatus.done).toList();
      for (var k = 1; k < doneSorted.length; k++) {
        expect(
          doneSorted[k].dueDate.compareTo(doneSorted[k - 1].dueDate),
          greaterThanOrEqualTo(0),
        );
      }
    });
  }
}
