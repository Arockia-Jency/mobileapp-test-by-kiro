import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_test_ai/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:mobile_test_ai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:mobile_test_ai/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository mockRepo;
  late GetDashboardSummaryUseCase useCase;

  setUp(() {
    mockRepo = MockDashboardRepository();
    useCase = GetDashboardSummaryUseCase(mockRepo);
  });

  test('returns DashboardSummary from repository', () async {
    const summary = DashboardSummary(
      isCheckedInToday: true,
      checkInTimeFormatted: '09:00',
      totalCustomers: 12,
      pendingActivities: 3,
    );
    when(() => mockRepo.getSummary()).thenAnswer((_) async => summary);

    final result = await useCase();

    expect(result, summary);
  });

  test('propagates exception from repository', () {
    when(() => mockRepo.getSummary()).thenThrow(Exception('error'));
    expect(() => useCase(), throwsA(isA<Exception>()));
  });
}
