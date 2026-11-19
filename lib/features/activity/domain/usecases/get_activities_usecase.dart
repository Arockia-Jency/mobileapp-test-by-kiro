import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/activity/domain/repositories/activity_repository.dart';

class GetActivitiesUseCase {
  final ActivityRepository _repository;

  const GetActivitiesUseCase(this._repository);

  Future<List<Activity>> call() => _repository.getAllActivities();
}
