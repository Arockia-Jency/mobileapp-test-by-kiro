import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/activity/domain/repositories/activity_repository.dart';

class MarkActivityDoneUseCase {
  final ActivityRepository _repository;

  const MarkActivityDoneUseCase(this._repository);

  Future<Activity> call(String activityId) => _repository.markDone(activityId);
}
