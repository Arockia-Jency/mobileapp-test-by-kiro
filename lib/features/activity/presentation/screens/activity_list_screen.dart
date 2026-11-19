import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_test_ai/core/router/app_router.dart';
import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_event.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_state.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ActivityBloc>().add(const ActivityLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Follow-Up Activities')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_activity_button'),
        onPressed: () => context.push(Routes.addActivity),
        icon: const Icon(Icons.add),
        label: const Text('Add Activity'),
      ),
      body: BlocBuilder<ActivityBloc, ActivityState>(
        builder: (context, state) {
          if (state is ActivityLoading || state is ActivityInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ActivityError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          if (state is ActivityLoaded) {
            if (state.activities.isEmpty) {
              return const Center(child: Text('No activities yet. Add one!'));
            }
            return ListView.separated(
              itemCount: state.activities.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = state.activities[index];
                return _ActivityListItem(activity: activity);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ActivityListItem extends StatelessWidget {
  final Activity activity;

  const _ActivityListItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    final isDone = activity.status == ActivityStatus.done;
    final dateStr = DateFormat('dd/MM/yyyy').format(activity.dueDate);
    final displayTitle = activity.title.length > 100
        ? '${activity.title.substring(0, 100)}…'
        : activity.title;

    return ListTile(
      key: Key('activity_item_${activity.id}'),
      leading: Icon(
        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isDone ? Colors.green : Colors.orange,
      ),
      title: Text(
        displayTitle,
        style: isDone
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text('${activity.customerName} · $dateStr'),
      trailing: isDone
          ? const Icon(Icons.check, color: Colors.green)
          : IconButton(
              key: Key('mark_done_${activity.id}'),
              icon: const Icon(Icons.done_outline),
              tooltip: 'Mark Done',
              onPressed: () {
                context
                    .read<ActivityBloc>()
                    .add(ActivityMarkedDone(activity.id));
              },
            ),
    );
  }
}
