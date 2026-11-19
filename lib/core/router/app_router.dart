import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_test_ai/features/activity/presentation/screens/activity_list_screen.dart';
import 'package:mobile_test_ai/features/activity/presentation/screens/add_activity_screen.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobile_test_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile_test_ai/features/check_in/presentation/screens/check_in_screen.dart';
import 'package:mobile_test_ai/features/customer/presentation/screens/customer_detail_screen.dart';
import 'package:mobile_test_ai/features/customer/presentation/screens/customer_list_screen.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/screens/dashboard_screen.dart';

abstract class Routes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const checkIn = '/check-in';
  static const customers = '/customers';
  static const customerDetail = '/customers/:id';
  static const activities = '/activities';
  static const addActivity = '/activities/add';
}

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: Routes.login,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: _guard,
    routes: [
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: Routes.checkIn,
        name: 'checkIn',
        builder: (context, state) => const CheckInScreen(),
      ),
      GoRoute(
        path: Routes.customers,
        name: 'customers',
        builder: (context, state) => const CustomerListScreen(),
      ),
      GoRoute(
        path: '/customers/:id',
        name: 'customerDetail',
        builder: (context, state) => CustomerDetailScreen(
          customerId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: Routes.activities,
        name: 'activities',
        builder: (context, state) => const ActivityListScreen(),
      ),
      GoRoute(
        path: Routes.addActivity,
        name: 'addActivity',
        builder: (context, state) => const AddActivityScreen(),
      ),
    ],
  );

  String? _guard(BuildContext context, GoRouterState state) {
    final isAuthenticated = authBloc.state is Authenticated;
    final isLoginRoute = state.matchedLocation == Routes.login;

    if (!isAuthenticated && !isLoginRoute) return Routes.login;
    if (isAuthenticated && isLoginRoute) return Routes.dashboard;
    return null;
  }
}

/// A [ChangeNotifier] that fires whenever a [Stream] emits.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
