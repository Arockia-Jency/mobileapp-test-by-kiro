import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/activity/domain/usecases/add_activity_usecase.dart';
import 'package:mobile_test_ai/features/activity/domain/usecases/get_activities_usecase.dart';
import 'package:mobile_test_ai/features/activity/domain/usecases/mark_activity_done_usecase.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_event.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_state.dart';

class MockGetActivitiesUseCase extends Mock implements GetActivitiesUseCase {}
class MockAddActivityUseCase extends Mock implements AddActivityUseCase {}
class MockMarkActivityDoneUseCase extends Mock implements MarkActivityDoneUseCase {}

final _today = DateTime.now();

final _pendingActivity = Activity(
  id: 'act_001',
  customerId: 'cust_001',
  customerName: 'Alice',
  title: 'Task A',
  dueDate: _today,
  status: ActivityStatus.pending,
);

final _doneActivity = _pendingActivity.copyWith(status: ActivityStatus.done);

void main() {
  late MockGetActivitiesUseCase mockGet;
  late MockAddActivityUseCase mockAdd;
  late MockMarkActivityDoneUseCase mockMarkDone;

  setUp(() {
    mockGet = MockGetActivitiesUseCase();
    mockAdd = MockAddActivityUseCase();
    mockMarkDone = MockMarkActivityDoneUseCase();
    registerFallbackValue(_pendingActivity);
  });

  test('initial state is ActivityInitial', () {
    final bloc = ActivityBloc(mockGet, mockAdd, mockMarkDone);
    expect(bloc.state, isA<ActivityInitial>());
    bloc.close();
  });

  blocTest<ActivityBloc, ActivityState>(
    'emits [ActivityLoading, ActivityLoaded] on ActivityLoadRequested',
    build: () {
      when(() => mockGet()).thenAnswer((_) async => [_pendingActivity]);
      return ActivityBloc(mockGet, mockAdd, mockMarkDone);
    },
    act: (bloc) => bloc.add(const ActivityLoadRequested()),
    expect: () => [isA<ActivityLoading>(), isA<ActivityLoaded>()],
  );

  blocTest<ActivityBloc, ActivityState>(
    'emits ActivityLoaded with pending before done after ActivityAdded',
    build: () {
      when(() => mockAdd(any())).thenAnswer((_) async {});
      when(() => mockGet()).thenAnswer((_) async => [_pendingActivity, _doneActivity]);
      return ActivityBloc(mockGet, mockAdd, mockMarkDone);
    },
    seed: () => ActivityLoaded([_doneActivity]),
    act: (bloc) => bloc.add(ActivityAdded(_pendingActivity)),
    expect: () => [isA<ActivityLoaded>()],
    verify: (bloc) {
      final state = bloc.state as ActivityLoaded;
      // Pending comes first
      expect(state.activities.first.status, ActivityStatus.pending);
    },
  );

  blocTest<ActivityBloc, ActivityState>(
    'marks activity as done on ActivityMarkedDone',
    build: () {
      when(() => mockMarkDone(any())).thenAnswer((_) async => _doneActivity);
      when(() => mockGet()).thenAnswer((_) async => [_doneActivity]);
      return ActivityBloc(mockGet, mockAdd, mockMarkDone);
    },
    seed: () => ActivityLoaded([_pendingActivity]),
    act: (bloc) => bloc.add(ActivityMarkedDone(_pendingActivity.id)),
    expect: () => [isA<ActivityLoaded>()],
    verify: (bloc) {
      final state = bloc.state as ActivityLoaded;
      expect(state.activities.first.status, ActivityStatus.done);
    },
  );

  blocTest<ActivityBloc, ActivityState>(
    'emits [ActivityLoading, ActivityError] when load fails',
    build: () {
      when(() => mockGet()).thenThrow(Exception('error'));
      return ActivityBloc(mockGet, mockAdd, mockMarkDone);
    },
    act: (bloc) => bloc.add(const ActivityLoadRequested()),
    expect: () => [isA<ActivityLoading>(), isA<ActivityError>()],
  );
}
