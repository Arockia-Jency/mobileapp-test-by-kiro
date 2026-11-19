import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_event.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_state.dart';
import 'package:mobile_test_ai/features/customer/domain/entities/customer.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_state.dart';
import 'package:intl/intl.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ActivityBloc>().add(const ActivityLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Details')),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          Customer? customer;
          if (state is CustomerLoaded) {
            try {
              customer = state.allCustomers.firstWhere(
                (c) => c.id == widget.customerId,
              );
            } catch (_) {
              customer = null;
            }
          }

          if (customer == null) {
            return const Center(child: Text('Customer not found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key: const Key('detail_full_name'),
                  customer.fullName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  key: const Key('detail_company'),
                  customer.companyName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.email,
                  label: 'Email',
                  value: customer.email,
                  valueKey: const Key('detail_email'),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: customer.phoneNumber,
                  valueKey: const Key('detail_phone'),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.notes,
                  label: 'Notes',
                  value: customer.notes,
                  valueKey: const Key('detail_notes'),
                ),
                const Divider(height: 24),
                Text(
                  'Follow-Up Activities',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                BlocBuilder<ActivityBloc, ActivityState>(
                  builder: (context, actState) {
                    if (actState is ActivityLoading || actState is ActivityInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (actState is ActivityLoaded) {
                      final activities = actState.activities
                          .where((a) => a.customerId == widget.customerId)
                          .toList();
                      if (activities.isEmpty) {
                        return const Text('No activities for this customer.');
                      }
                      return Column(
                        children: activities
                            .map((a) => _ActivitySummaryItem(activity: a))
                            .toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Key? valueKey;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey)),
              Text(
                key: valueKey,
                value ?? 'Not available',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivitySummaryItem extends StatelessWidget {
  final Activity activity;

  const _ActivitySummaryItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    final isDone = activity.status == ActivityStatus.done;
    final dateStr = DateFormat('dd/MM/yyyy').format(activity.dueDate);

    return ListTile(
      dense: true,
      leading: Icon(
        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isDone ? Colors.green : Colors.orange,
      ),
      title: Text(
        activity.title.length > 100
            ? '${activity.title.substring(0, 100)}…'
            : activity.title,
        style: isDone
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(dateStr),
      trailing: Text(
        isDone ? 'Done' : 'Pending',
        style: TextStyle(color: isDone ? Colors.green : Colors.orange),
      ),
    );
  }
}
