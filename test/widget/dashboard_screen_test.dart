import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_bloc.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_event.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_state.dart';
import 'package:mobile_test_ai/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/screens/dashboard_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockDashboardBloc extends MockBloc<DashboardEvent, DashboardState> implements DashboardBloc {}
class MockCheckInBloc extends MockBloc<CheckInEvent, CheckInState> implements CheckInBloc {}

void main() {
  testWidgets('DashboardScreen renders summary cards when DashboardLoaded',
      (tester) async {
    final mockAuth = MockAuthBloc();
    final mockDash = MockDashboardBloc();
    final mockCheckIn = MockCheckInBloc();

    when(() => mockAuth.state).thenReturn(const Unauthenticated());
    when(() => mockCheckIn.state).thenReturn(const NotCheckedIn());
    when(() => mockDash.state).thenReturn(
      const DashboardLoaded(
        DashboardSummary(
          isCheckedInToday: false,
          totalCustomers: 12,
          pendingActivities: 3,
        ),
      ),
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuth),
          BlocProvider<DashboardBloc>.value(value: mockDash),
          BlocProvider<CheckInBloc>.value(value: mockCheckIn),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    expect(find.byKey(const Key('total_customers_card')), findsOneWidget);
    expect(find.byKey(const Key('pending_activities_card')), findsOneWidget);
    expect(find.byKey(const Key('checkin_status_card')), findsOneWidget);
  });
}
