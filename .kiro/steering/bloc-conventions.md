---
inclusion: always
---

# BLoC Conventions Steering — MobileTestAI

This file defines BLoC naming patterns, event/state structure, and testing patterns. All AI agents must follow these rules when generating or modifying BLoC files.

---

## Rule 1: BLoC Naming Patterns

- BLoC class: `<Feature>Bloc` extending `Bloc<FeatureEvent, FeatureState>`.
- Event base class: `<Feature>Event` (abstract + `Equatable`).
- State base class: `<Feature>State` (abstract + `Equatable`).
- Concrete events: imperative present/past tense verb phrase — `LoginSubmitted`, `ActivityAdded`, `DashboardLoadRequested`.
- Concrete states: noun or adjective describing the UI condition — `Authenticated`, `ActivityLoaded`, `DashboardError`.

✅ **GOOD**:
```dart
class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({required this.email, required this.password});
}
class Authenticated extends AuthState {
  final Employee employee;
  const Authenticated(this.employee);
}
```

❌ **BAD** — imperative verb in state, noun in event:
```dart
class DoLogin extends AuthEvent { ... }         // VIOLATION — imperative command
class AuthSuccess extends AuthState { ... }     // acceptable, but prefer Authenticated
```

---

## Rule 2: Event and State File Structure

- Each BLoC MUST define its events in `<feature>_event.dart` and its states in `<feature>_state.dart`, separate from `<feature>_bloc.dart`.
- All state classes MUST extend `Equatable` and override `props` with every field.
- States that carry data MUST be immutable (all fields `final`).
- BLoC async handlers MUST wrap use-case calls in `try/catch`, emit a loading state before the call, and emit an error state on exception.

✅ **GOOD** — separate files, equatable props:
```dart
// auth_state.dart
class Authenticated extends AuthState {
  final Employee employee;
  const Authenticated(this.employee);
  @override
  List<Object?> get props => [employee];
}
```

❌ **BAD** — missing props override:
```dart
class Authenticated extends AuthState {
  final Employee employee;
  const Authenticated(this.employee);
  // VIOLATION: no props override — equatable equality broken
}
```

---

## Rule 3: BLoC Testing Patterns

- Use `bloc_test` package exclusively; never test BLoCs with raw `StreamSubscription` or manual stream listening.
- Each `blocTest` call MUST have a descriptive string naming the scenario.
- Happy-path test: `act` = happy event, `expect` = `[loadingState, successState]`.
- Failure test: `act` = failure-triggering event, `expect` = `[loadingState, errorState]`.
- Use `mocktail` to mock repository or use-case dependencies passed via constructor.

✅ **GOOD**:
```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthenticatingInProgress, Authenticated] on valid login',
  build: () {
    when(() => mockUseCase(any(), any())).thenAnswer((_) async => testEmployee);
    return AuthBloc(mockUseCase);
  },
  act: (bloc) => bloc.add(LoginSubmitted(email: 'demo@example.com', password: 'password123')),
  expect: () => [isA<AuthenticatingInProgress>(), isA<Authenticated>()],
);
```

❌ **BAD** — testing BLoC through widget pump instead of blocTest:
```dart
testWidgets('logs in', (tester) async {
  await tester.pumpWidget(app);
  await tester.tap(find.byKey(Key('login_button')));
  // VIOLATION: BLoC logic tested via widget test; use blocTest instead
});
```
