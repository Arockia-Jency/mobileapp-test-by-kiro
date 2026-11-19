import 'package:mobile_test_ai/features/check_in/domain/entities/check_in_record.dart';

abstract class CheckInRepository {
  /// Records check-in at the current device time. Returns the new [CheckInRecord].
  Future<CheckInRecord> checkIn();

  /// Records check-out on [existing]. Throws [StateError] if already checked out.
  Future<CheckInRecord> checkOut(CheckInRecord existing);
}
