import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/activity/domain/repositories/activity_repository.dart';
import 'package:mobile_test_ai/features/mock_data/mock_data_source.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final MockDataSource _source;

  ActivityRepositoryImpl(this._source);

  @override
  Future<List<Activity>> getAllActivities() async {
    return List.unmodifiable(_source.activities);
  }

  @override
  Future<void> addActivity(Activity activity) async {
    _source.activities.add(activity);
  }

  @override
  Future<Activity> markDone(String activityId) async {
    final index = _source.activities.indexWhere((a) => a.id == activityId);
    if (index == -1) throw StateError('Activity $activityId not found.');
    final activity = _source.activities[index];
    if (activity.status == ActivityStatus.done) {
      throw StateError('Activity $activityId is already done.');
    }
    final updated = activity.copyWith(status: ActivityStatus.done);
    _source.activities[index] = updated;
    return updated;
  }
}
