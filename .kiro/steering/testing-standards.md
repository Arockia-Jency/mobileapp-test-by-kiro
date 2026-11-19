---
inclusion: always
---

# Testing Standards Steering — MobileTestAI

This file defines the test file location convention, tool usage rules, and minimum coverage expectations. All AI agents must follow these rules when generating or modifying test files.

---

## Rule 1: Test File Location Convention

- Every source file at `lib/features/<feature>/<layer>/` MUST have a corresponding test at `test/features/<feature>/<layer>/`.
- Widget tests for screens live under `test/widget/`.
- Integration tests live under `test/integration_test/`.
- Property-based tests live alongside their corresponding unit test files.

✅ **GOOD** — mirrored structure:
```
lib/features/auth/domain/usecases/login_usecase.dart
→ test/features/auth/domain/usecases/login_usecase_test.dart
```

❌ **BAD** — placing BLoC tests with widget tests:
```
test/widget/auth_bloc_test.dart  // VIOLATION — BLoC tests belong in test/features/
```

---

## Rule 2: Tool Usage

- BLoC tests MUST use `bloc_test` helpers (`blocTest`, `build`, `act`, `expect`, `verify`).
- UseCase tests that require a repository MUST mock with `mocktail` (`Mock`, `when`, `verify`).
- Widget tests MUST use `flutter_test`'s `testWidgets` and `WidgetTester`.
- Property tests use a manual parametric loop of ≥ 100 iterations (or `dart_test_property`/`fast_check` if available).

✅ **GOOD** — mocktail stub:
```dart
when(() => mockRepo.getAllCustomers()).thenAnswer((_) async => customers);
```

❌ **BAD** — hand-rolled stub class:
```dart
class StubCustomerRepo implements CustomerRepository {
  @override
  Future<List<Customer>> getAllCustomers() async => customers;
  // VIOLATION: use mocktail instead
}
```

---

## Rule 3: Coverage Target

- Run `flutter test --coverage` to generate `coverage/lcov.info`.
- The project MUST achieve at minimum **80% line coverage** across all files matching:
  - `lib/features/*/presentation/bloc/*.dart`
  - `lib/features/*/domain/usecases/*.dart`
- Coverage is checked with:
  ```bash
  flutter test --coverage
  genhtml coverage/lcov.info -o coverage/html
  ```

✅ **GOOD**:
```
# CI step that fails below 80%
flutter test --coverage && lcov --summary coverage/lcov.info
```

❌ **BAD** — shipping a feature without any BLoC test:
```
# No test file exists for DashboardBloc  // VIOLATION
```
