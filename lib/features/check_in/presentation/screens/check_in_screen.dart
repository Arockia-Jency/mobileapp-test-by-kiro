import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_bloc.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_event.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_state.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-In / Check-Out')),
      body: BlocConsumer<CheckInBloc, CheckInState>(
        listener: (context, state) {
          if (state is CheckInError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, size: 64, color: Colors.blueGrey),
                  const SizedBox(height: 24),
                  _buildStatusContent(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusContent(BuildContext context, CheckInState state) {
    if (state is NotCheckedIn || state is CheckInError) {
      return Column(
        children: [
          Text(
            key: const Key('status_label'),
            'Not Checked In',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            key: const Key('check_in_button'),
            onPressed: () => context.read<CheckInBloc>().add(const CheckInRequested()),
            icon: const Icon(Icons.login),
            label: const Text('Check In'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
        ],
      );
    }

    if (state is CheckedIn) {
      return Column(
        children: [
          Text(
            key: const Key('status_label'),
            'Checked In',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.green),
          ),
          const SizedBox(height: 8),
          Text(
            key: const Key('checkin_time_label'),
            'Checked in at ${state.record.checkInFormatted}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            key: const Key('check_out_button'),
            onPressed: () => context.read<CheckInBloc>().add(const CheckOutRequested()),
            icon: const Icon(Icons.logout),
            label: const Text('Check Out'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      );
    }

    if (state is CheckedOut) {
      return Column(
        children: [
          Text(
            key: const Key('status_label'),
            'Checked Out',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            key: const Key('checkin_time_label'),
            'Checked in: ${state.record.checkInFormatted}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            key: const Key('checkout_time_label'),
            'Checked out: ${state.record.checkOutFormatted}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                key: const Key('check_in_button'),
                onPressed: null,
                icon: const Icon(Icons.login),
                label: const Text('Check In'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                key: const Key('check_out_button'),
                onPressed: null,
                icon: const Icon(Icons.logout),
                label: const Text('Check Out'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Session ended for today.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
