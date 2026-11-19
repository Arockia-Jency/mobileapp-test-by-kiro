import 'package:equatable/equatable.dart';
import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();
}

class ActivityLoadRequested extends ActivityEvent {
  const ActivityLoadRequested();

  @override
  List<Object?> get props => [];
}

class ActivityAdded extends ActivityEvent {
  final Activity activity;

  const ActivityAdded(this.activity);

  @override
  List<Object?> get props => [activity];
}

class ActivityMarkedDone extends ActivityEvent {
  final String activityId;

  const ActivityMarkedDone(this.activityId);

  @override
  List<Object?> get props => [activityId];
}
