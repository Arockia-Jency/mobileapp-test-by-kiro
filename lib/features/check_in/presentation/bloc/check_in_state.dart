import 'package:equatable/equatable.dart';
import 'package:mobile_test_ai/features/check_in/domain/entities/check_in_record.dart';

abstract class CheckInState extends Equatable {
  const CheckInState();
}

class NotCheckedIn extends CheckInState {
  const NotCheckedIn();

  @override
  List<Object?> get props => [];
}

class CheckedIn extends CheckInState {
  final CheckInRecord record;

  const CheckedIn(this.record);

  @override
  List<Object?> get props => [record];
}

class CheckedOut extends CheckInState {
  final CheckInRecord record;

  const CheckedOut(this.record);

  @override
  List<Object?> get props => [record];
}

class CheckInError extends CheckInState {
  final String message;

  const CheckInError(this.message);

  @override
  List<Object?> get props => [message];
}
