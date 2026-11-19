import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/activity/domain/repositories/activity_repository.dart';

class AddActivityUseCase {
  final ActivityRepository _repository;

  const AddActivityUseCase(this._repository);

  Future<void> call(Activity activity) => _repository.addActivity(activity);
}
