import 'package:equatable/equatable.dart';

abstract class CheckInEvent extends Equatable {
  const CheckInEvent();
}

class CheckInRequested extends CheckInEvent {
  const CheckInRequested();

  @override
  List<Object?> get props => [];
}

class CheckOutRequested extends CheckInEvent {
  const CheckOutRequested();

  @override
  List<Object?> get props => [];
}
