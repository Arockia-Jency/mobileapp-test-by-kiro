import 'package:equatable/equatable.dart';

class CheckInRecord extends Equatable {
  final DateTime checkInTime;
  final DateTime? checkOutTime;

  const CheckInRecord({
    required this.checkInTime,
    this.checkOutTime,
  });

  /// Returns check-in time formatted as HH:mm.
  String get checkInFormatted =>
      '${checkInTime.hour.toString().padLeft(2, '0')}:${checkInTime.minute.toString().padLeft(2, '0')}';

  /// Returns check-out time formatted as HH:mm, or null if not checked out.
  String? get checkOutFormatted => checkOutTime == null
      ? null
      : '${checkOutTime!.hour.toString().padLeft(2, '0')}:${checkOutTime!.minute.toString().padLeft(2, '0')}';

  CheckInRecord copyWith({DateTime? checkOutTime}) {
    return CheckInRecord(
      checkInTime: checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
    );
  }

  @override
  List<Object?> get props => [checkInTime, checkOutTime];
}
