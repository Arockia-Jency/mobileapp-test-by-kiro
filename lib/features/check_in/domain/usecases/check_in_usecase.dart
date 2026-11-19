import 'package:mobile_test_ai/features/check_in/domain/entities/check_in_record.dart';
import 'package:mobile_test_ai/features/check_in/domain/repositories/check_in_repository.dart';

class CheckInUseCase {
  final CheckInRepository _repository;

  const CheckInUseCase(this._repository);

  Future<CheckInRecord> call() => _repository.checkIn();
}
