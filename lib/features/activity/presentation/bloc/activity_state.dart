import 'package:equatable/equatable.dart';
import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();
}

class ActivityInitial extends ActivityState {
  const ActivityInitial();

  @override
  List<Object?> get props => [];
}

class ActivityLoading extends ActivityState {
  const ActivityLoading();

  @override
  List<Object?> get props => [];
}

class ActivityLoaded extends ActivityState {
  final List<Activity> activities;

  const ActivityLoaded(this.activities);

  @override
  List<Object?> get props => [activities];
}

class ActivityError extends ActivityState {
  final String message;

  const ActivityError(this.message);

  @override
  List<Object?> get props => [message];
}
