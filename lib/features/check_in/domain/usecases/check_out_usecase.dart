import 'package:mobile_test_ai/features/check_in/domain/entities/check_in_record.dart';
import 'package:mobile_test_ai/features/check_in/domain/repositories/check_in_repository.dart';

class CheckOutUseCase {
  final CheckInRepository _repository;

  const CheckOutUseCase(this._repository);

  Future<CheckInRecord> call(CheckInRecord existing) => _repository.checkOut(existing);
}
