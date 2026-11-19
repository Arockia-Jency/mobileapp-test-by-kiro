import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_test_ai/features/check_in/domain/usecases/check_in_usecase.dart';
import 'package:mobile_test_ai/features/check_in/domain/usecases/check_out_usecase.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_event.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_state.dart';

class CheckInBloc extends Bloc<CheckInEvent, CheckInState> {
  final CheckInUseCase _checkInUseCase;
  final CheckOutUseCase _checkOutUseCase;

  CheckInBloc(this._checkInUseCase, this._checkOutUseCase)
      : super(const NotCheckedIn()) {
    on<CheckInRequested>(_onCheckInRequested);
    on<CheckOutRequested>(_onCheckOutRequested);
  }

  Future<void> _onCheckInRequested(
    CheckInRequested event,
    Emitter<CheckInState> emit,
  ) async {
    // No-op if already checked out
    if (state is CheckedOut) return;
    // No-op if already checked in
    if (state is CheckedIn) return;

    try {
      final record = await _checkInUseCase();
      emit(CheckedIn(record));
    } catch (e, st) {
      debugPrint('CheckInBloc check-in error: $e\n$st');
      emit(const CheckInError('Failed to check in. Please try again.'));
      emit(const NotCheckedIn());
    }
  }

  Future<void> _onCheckOutRequested(
    CheckOutRequested event,
    Emitter<CheckInState> emit,
  ) async {
    // Guard: cannot check out before checking in
    if (state is NotCheckedIn) {
      emit(const CheckInError('You must check in before checking out.'));
      emit(const NotCheckedIn());
      return;
    }

    // No-op if already checked out
    if (state is CheckedOut) return;

    final currentState = state as CheckedIn;
    try {
      final updated = await _checkOutUseCase(currentState.record);
      emit(CheckedOut(updated));
    } catch (e, st) {
      debugPrint('CheckInBloc check-out error: $e\n$st');
      emit(const CheckInError('Failed to check out. Please try again.'));
      emit(CheckedIn(currentState.record));
    }
  }
}
