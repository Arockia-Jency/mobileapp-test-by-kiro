import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/activity/domain/usecases/add_activity_usecase.dart';
import 'package:mobile_test_ai/features/activity/domain/usecases/get_activities_usecase.dart';
import 'package:mobile_test_ai/features/activity/domain/usecases/mark_activity_done_usecase.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_event.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final GetActivitiesUseCase _getActivities;
  final AddActivityUseCase _addActivity;
  final MarkActivityDoneUseCase _markDone;

  ActivityBloc(this._getActivities, this._addActivity, this._markDone)
      : super(const ActivityInitial()) {
    on<ActivityLoadRequested>(_onLoad);
    on<ActivityAdded>(_onAdded);
    on<ActivityMarkedDone>(_onMarkedDone);
  }

  Future<void> _onLoad(ActivityLoadRequested event, Emitter<ActivityState> emit) async {
    emit(const ActivityLoading());
    try {
      final activities = await _getActivities();
      emit(ActivityLoaded(_sortActivities(activities)));
    } catch (e, st) {
      debugPrint('ActivityBloc load error: $e\n$st');
      emit(const ActivityError('Could not load activities. Please try again.'));
    }
  }

  Future<void> _onAdded(ActivityAdded event, Emitter<ActivityState> emit) async {
    try {
      await _addActivity(event.activity);
      final activities = await _getActivities();
      emit(ActivityLoaded(_sortActivities(activities)));
    } catch (e, st) {
      debugPrint('ActivityBloc add error: $e\n$st');
      emit(const ActivityError('Could not add activity. Please try again.'));
    }
  }

  Future<void> _onMarkedDone(ActivityMarkedDone event, Emitter<ActivityState> emit) async {
    try {
      await _markDone(event.activityId);
      final activities = await _getActivities();
      emit(ActivityLoaded(_sortActivities(activities)));
    } catch (e, st) {
      debugPrint('ActivityBloc markDone error: $e\n$st');
      emit(const ActivityError('Could not update activity. Please try again.'));
    }
  }

  /// Sorts activities: pending ascending by dueDate, then done ascending by dueDate.
  static List<Activity> _sortActivities(List<Activity> raw) {
    final pending = raw
        .where((a) => a.status == ActivityStatus.pending)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final done = raw
        .where((a) => a.status == ActivityStatus.done)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return [...pending, ...done];
  }
}
