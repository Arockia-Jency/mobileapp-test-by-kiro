import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_test_ai/features/mock_data/mock_data_source.dart';

void main() {
  setUp(() => MockDataSource.instance.resetSession());

  test('MockDataSource is a singleton', () {
    final a = MockDataSource.instance;
    final b = MockDataSource.instance;
    expect(identical(a, b), isTrue);
  });

  test('customers list has at least 10 records', () {
    expect(MockDataSource.instance.customers.length, greaterThanOrEqualTo(10));
  });

  test('activities list is non-empty after seed', () {
    expect(MockDataSource.instance.activities.isNotEmpty, isTrue);
  });

  test('nextActivityId returns unique values', () {
    final ids = List.generate(50, (_) => MockDataSource.instance.nextActivityId());
    expect(ids.toSet().length, 50);
  });

  test('resetSession clears todayCheckIn', () {
    MockDataSource.instance.todayCheckIn = null;
    MockDataSource.instance.resetSession();
    expect(MockDataSource.instance.todayCheckIn, isNull);
  });
}
