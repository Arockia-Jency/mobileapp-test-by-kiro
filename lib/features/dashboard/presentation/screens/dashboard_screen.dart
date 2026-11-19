import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_test_ai/core/router/app_router.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_bloc.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_state.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckInBloc, CheckInState>(
      listener: (context, state) {
        if (state is CheckedIn || state is CheckedOut) {
          context.read<DashboardBloc>().add(const DashboardRefreshRequested());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              key: const Key('logout_button'),
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                context.read<AuthBloc>().add(const LogoutRequested());
              },
            ),
          ],
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return Center(
                child: Text(
                  key: const Key('dashboard_error'),
                  state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }

            if (state is DashboardLoaded) {
              final summary = state.summary;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SummaryCard(
                      key: const Key('checkin_status_card'),
                      title: 'Check-In Status',
                      value: summary.isCheckedInToday
                          ? 'Checked In${summary.checkInTimeFormatted != null ? ' at ${summary.checkInTimeFormatted}' : ''}'
                          : 'Not Checked In',
                      icon: Icons.access_time,
                      color: summary.isCheckedInToday ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      key: const Key('total_customers_card'),
                      title: 'Total Customers',
                      value: summary.totalCustomers.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      key: const Key('pending_activities_card'),
                      title: 'Pending Activities',
                      value: summary.pendingActivities.toString(),
                      icon: Icons.task_alt,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            key: const Key('checkin_action'),
                            label: 'Check In / Check Out',
                            icon: Icons.login,
                            onTap: () => context.push(Routes.checkIn),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            key: const Key('customers_action'),
                            label: 'View Customers',
                            icon: Icons.contacts,
                            onTap: () => context.push(Routes.customers),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: Theme.of(context).textTheme.bodySmall),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label, textAlign: TextAlign.center),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      ),
    );
  }
}
