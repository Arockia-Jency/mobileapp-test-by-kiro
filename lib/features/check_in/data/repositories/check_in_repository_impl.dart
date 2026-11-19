import 'package:mobile_test_ai/features/check_in/domain/entities/check_in_record.dart';
import 'package:mobile_test_ai/features/check_in/domain/repositories/check_in_repository.dart';
import 'package:mobile_test_ai/features/mock_data/mock_data_source.dart';

class CheckInRepositoryImpl implements CheckInRepository {
  final MockDataSource _source;

  CheckInRepositoryImpl(this._source);

  @override
  Future<CheckInRecord> checkIn() async {
    final record = CheckInRecord(checkInTime: DateTime.now());
    _source.todayCheckIn = record;
    return record;
  }

  @override
  Future<CheckInRecord> checkOut(CheckInRecord existing) async {
    if (existing.checkOutTime != null) {
      throw StateError('Already checked out.');
    }
    final updated = existing.copyWith(checkOutTime: DateTime.now());
    _source.todayCheckIn = updated;
    return updated;
  }
}
