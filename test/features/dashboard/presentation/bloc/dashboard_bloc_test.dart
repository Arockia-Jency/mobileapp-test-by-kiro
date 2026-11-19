import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_test_ai/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:mobile_test_ai/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/bloc/dashboard_state.dart';

class MockGetDashboardSummaryUseCase extends Mock
    implements GetDashboardSummaryUseCase {}

const _testSummary = DashboardSummary(
  isCheckedInToday: false,
  totalCustomers: 12,
  pendingActivities: 3,
);

void main() {
  late MockGetDashboardSummaryUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetDashboardSummaryUseCase();
  });

  test('initial state is DashboardInitial', () {
    final bloc = DashboardBloc(mockUseCase);
    expect(bloc.state, isA<DashboardInitial>());
    bloc.close();
  });

  blocTest<DashboardBloc, DashboardState>(
    'emits [DashboardLoading, DashboardLoaded] on successful load',
    build: () {
      when(() => mockUseCase()).thenAnswer((_) async => _testSummary);
      return DashboardBloc(mockUseCase);
    },
    act: (bloc) => bloc.add(const DashboardLoadRequested()),
    expect: () => [isA<DashboardLoading>(), isA<DashboardLoaded>()],
  );

  blocTest<DashboardBloc, DashboardState>(
    'emits [DashboardLoading, DashboardError] when use case throws',
    build: () {
      when(() => mockUseCase()).thenThrow(Exception('error'));
      return DashboardBloc(mockUseCase);
    },
    act: (bloc) => bloc.add(const DashboardLoadRequested()),
    expect: () => [isA<DashboardLoading>(), isA<DashboardError>()],
  );

  blocTest<DashboardBloc, DashboardState>(
    'DashboardRefreshRequested also triggers load',
    build: () {
      when(() => mockUseCase()).thenAnswer((_) async => _testSummary);
      return DashboardBloc(mockUseCase);
    },
    act: (bloc) => bloc.add(const DashboardRefreshRequested()),
    expect: () => [isA<DashboardLoading>(), isA<DashboardLoaded>()],
  );
}
