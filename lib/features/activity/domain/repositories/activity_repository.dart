import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';

abstract class ActivityRepository {
  Future<List<Activity>> getAllActivities();
  Future<void> addActivity(Activity activity);
  /// Marks the activity with [activityId] as done.
  /// Throws [StateError] if the activity is already done.
  Future<Activity> markDone(String activityId);
}
