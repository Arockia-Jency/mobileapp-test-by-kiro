# Implementation Plan: MobileTestAI POC

## Overview

Build a Flutter employee field-management app demonstrating Kiro IDE's AI-assisted development workflow. The app uses Clean Architecture, BLoC state management, and an in-memory mock data layer. Implementation is sequenced so each phase compiles and tests pass before the next phase begins. Dart/Flutter is the implementation language throughout.

## Tasks

- [ ] 1. Project foundation — dependencies, folder skeleton, and main.dart wiring
  - [ ] 1.1 Update `pubspec.yaml` with all required runtime and dev dependencies
    - Add `flutter_bloc: ^9.0.0`, `equatable: ^2.0.0`, `go_router: ^14.0.0`, `intl: ^0.19.0` under `dependencies`
    - Add `mocktail: ^1.0.0`, `bloc_test: ^10.0.0` under `dev_dependencies`
    - File to modify: `pubspec.yaml`
    - _Requirements: 7.5, 7.6_

  - [ ] 1.2 Create the complete `lib/` and `test/` folder skeleton
    - Create all directories defined in the design's folder structure (do not create files yet, just empty `.gitkeep` files or the first real files)
    - Directories: `lib/core/di/`, `lib/core/router/`, `lib/core/validation/`, `lib/features/auth/domain/entities/`, `lib/features/auth/domain/repositories/`, `lib/features/auth/domain/usecases/`, `lib/features/auth/data/repositories/`, `lib/features/auth/presentation/bloc/`, `lib/features/auth/presentation/screens/`, same `domain/data/presentation` structure for `dashboard/`, `check_in/`, `customer/`, `activity/`, `lib/features/mock_data/`
    - Mirror under `test/features/auth/`, `test/features/dashboard/`, `test/features/check_in/`, `test/features/customer/`, `test/features/activity/`, `test/widget/`, `test/integration_test/`
    - _Requirements: 7.1_

  - [ ] 1.3 Create stub `main.dart` that compiles with a placeholder `runApp`
    - File: `lib/main.dart` — write minimal `void main() => runApp(const Placeholder());` so `flutter analyze` passes from the start
    - _Requirements: 7.1_

- [ ] 2. Core layer — validators, router shell, and service locator shell
  - [ ] 2.1 Implement `EmailValidator` and `PasswordValidator`
    - File: `lib/core/validation/email_validator.dart` — static `String? validate(String? value)` enforcing non-empty, `local@domain.tld`, local-part 1–64 chars, domain 1–255 chars
    - File: `lib/core/validation/password_validator.dart` — static `String? validate(String? value)` enforcing 6–128 chars, non-empty
    - _Requirements: 6.1, 6.2_

  - [ ] 2.2 Implement `ActivityValidator`
    - File: `lib/core/validation/activity_validator.dart` — static `validateTitle`, `validateDueDate`, `validateCustomer` as specified in the design
    - _Requirements: 6.5, 6.6, 6.7_

  - [ ] 2.3 Create stub `AppRouter` with named route constants only
    - File: `lib/core/router/app_router.dart` — define `Routes` abstract class with all six path constants; define `AppRouter` class with a `GoRouter router` field that lists all routes pointing to `Placeholder` builders; no auth guard yet
    - _Requirements: 7.9_

  - [ ] 2.4 Create stub `ServiceLocator` with field declarations and an empty `setup()` method
    - File: `lib/core/di/service_locator.dart` — declare all `late final` fields from the design; `setup()` body left empty for now
    - _Requirements: 7.1_

- [ ] 3. MockDataSource — in-memory singleton with all seed data
  - [ ] 3.1 Implement `MockDataSource` singleton with employee, check-in record, 12 customers, and 6 seeded activities
    - File: `lib/features/mock_data/mock_data_source.dart`
    - Include `demoEmail`, `demoPassword`, `currentEmployee`, nullable `todayCheckIn`, `customers` list (all 12 records from the design), `activities` list seeded by `_seedActivities()`, `nextActivityId()`, and `simulateError` flag (default `false`)
    - _Requirements: 1.3, 4.9_

  - [ ]* 3.2 Write unit tests for `MockDataSource`
    - File: `test/features/mock_data/mock_data_source_test.dart`
    - Assert singleton pattern, customer list length ≥ 10, activity list non-empty, `nextActivityId()` returns unique values on successive calls
    - _Requirements: 4.9_

- [ ] 4. Auth feature — entity, repository interface, use case, data layer, BLoC, login screen
  - [ ] 4.1 Implement `Employee` entity
    - File: `lib/features/auth/domain/entities/employee.dart`
    - Extend `Equatable`, immutable, fields: `id`, `name`, `email`; override `props`; zero Flutter imports
    - _Requirements: 7.2_

  - [ ] 4.2 Implement `AuthRepository` interface and `LoginUseCase`
    - File: `lib/features/auth/domain/repositories/auth_repository.dart` — abstract class with `Future<Employee> login({required String email, required String password})`; throws `AuthException('invalid_credentials')` on mismatch
    - File: `lib/features/auth/domain/usecases/login_usecase.dart` — `LoginUseCase` with `Future<Employee> call(String email, String password)` delegating to the repository; constructor-injected `AuthRepository`
    - _Requirements: 1.3, 7.2, 7.8_

  - [ ] 4.3 Implement `AuthRepositoryImpl`
    - File: `lib/features/auth/data/repositories/auth_repository_impl.dart`
    - Constructor-inject `MockDataSource`; compare email/password to `_source.demoEmail`/`_source.demoPassword`; return `_source.currentEmployee` on match; throw `AuthException('invalid_credentials')` otherwise
    - _Requirements: 1.3_

  - [ ] 4.4 Implement `AuthBloc` with events and states
    - File: `lib/features/auth/presentation/bloc/auth_state.dart` — sealed/abstract base `AuthState extends Equatable`; four concrete states: `Unauthenticated`, `AuthenticatingInProgress`, `Authenticated { Employee employee }`, `AuthenticationFailed { String message }` — all with `props`
    - File: `lib/features/auth/presentation/bloc/auth_event.dart` — abstract `AuthEvent extends Equatable`; concrete: `LoginSubmitted { String email, String password }`, `LogoutRequested`
    - File: `lib/features/auth/presentation/bloc/auth_bloc.dart` — `AuthBloc extends Bloc<AuthEvent, AuthState>`; handle `LoginSubmitted` (emit `AuthenticatingInProgress` then `Authenticated` or `AuthenticationFailed`); handle `LogoutRequested` (emit `Unauthenticated`); guard against re-login when already `Authenticated`
    - _Requirements: 1.3, 1.5, 1.7, 1.9_

  - [ ] 4.5 Implement `LoginScreen`
    - File: `lib/features/auth/presentation/screens/login_screen.dart`
    - `BlocConsumer<AuthBloc, AuthState>`; email `TextField` (key `'email_field'`, maxLength 254), password `TextField` (key `'password_field'`, obscureText, maxLength 128), submit `ElevatedButton` (key `'login_button'`, disabled when `AuthenticatingInProgress`), `CircularProgressIndicator` (visible when `AuthenticatingInProgress`), error `Text` (key `'auth_error'`, visible when `AuthenticationFailed`)
    - Validate inputs via `EmailValidator` and `PasswordValidator` on submission; show inline errors without dispatching `LoginSubmitted` if validation fails
    - _Requirements: 1.1, 1.2, 1.5, 1.6, 1.7, 1.10, 6.1, 6.2, 6.3_

  - [ ]* 4.6 Write unit tests for `LoginUseCase`
    - File: `test/features/auth/domain/usecases/login_usecase_test.dart`
    - Use `mocktail` mock of `AuthRepository`; test: returns `Employee` on matching credentials; propagates `AuthException` on invalid credentials
    - _Requirements: 8.2, 8.6_

  - [ ]* 4.7 Write BLoC tests for `AuthBloc`
    - File: `test/features/auth/presentation/bloc/auth_bloc_test.dart`
    - Use `bloc_test`; cover: initial state is `Unauthenticated`; emits `[AuthenticatingInProgress, Authenticated]` on valid login; emits `[AuthenticatingInProgress, AuthenticationFailed]` on invalid login; emits `Unauthenticated` on `LogoutRequested`
    - _Requirements: 8.1, 8.5_

  - [ ]* 4.8 Write widget test for `LoginScreen`
    - File: `test/widget/login_screen_test.dart`
    - Assert screen renders without throwing; find `email_field`, `password_field`, `login_button`
    - _Requirements: 8.3_

- [ ] 5. Dashboard feature — entity, repository interface, use case, data layer, BLoC, dashboard screen
  - [ ] 5.1 Implement `DashboardSummary` entity
    - File: `lib/features/dashboard/domain/entities/dashboard_summary.dart`
    - `DashboardSummary extends Equatable`; fields: `isCheckedInToday`, `checkInTimeFormatted?`, `totalCustomers`, `pendingActivities`; override `props`; zero Flutter imports
    - _Requirements: 7.2_

  - [ ] 5.2 Implement `DashboardRepository` interface and `GetDashboardSummaryUseCase`
    - File: `lib/features/dashboard/domain/repositories/dashboard_repository.dart`
    - File: `lib/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart` — `Future<DashboardSummary> call()` with constructor-injected `DashboardRepository`
    - _Requirements: 2.3, 2.4, 2.8, 7.8_

  - [ ] 5.3 Implement `DashboardRepositoryImpl`
    - File: `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart`
    - Derive `isCheckedInToday` from `_source.todayCheckIn`, `totalCustomers` from `_source.customers.length`, `pendingActivities` from activities where `status == pending && dueDate <= today`; throw `DataSourceException` when `_source.simulateError` is `true`
    - _Requirements: 2.2, 2.3, 2.4, 2.8_

  - [ ] 5.4 Implement `DashboardBloc` with events and states
    - File: `lib/features/dashboard/presentation/bloc/dashboard_state.dart` — `DashboardInitial`, `DashboardLoading`, `DashboardLoaded { DashboardSummary summary }`, `DashboardError { String message }`
    - File: `lib/features/dashboard/presentation/bloc/dashboard_event.dart` — `DashboardLoadRequested`, `DashboardRefreshRequested`
    - File: `lib/features/dashboard/presentation/bloc/dashboard_bloc.dart` — handle both events with `try/catch`; emit `DashboardLoading` then `DashboardLoaded` or `DashboardError`
    - _Requirements: 2.9, 2.11_

  - [ ] 5.5 Implement `DashboardScreen`
    - File: `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
    - `MultiBlocProvider` consumer; `AppBar` with logout `IconButton` (key `'logout_button'`); `BlocBuilder<DashboardBloc, DashboardState>` rendering `CircularProgressIndicator` while loading, error `Text` (key `'dashboard_error'`) on error, or the loaded column with `CheckInStatusCard` (key `'checkin_status_card'`), `SummaryCard` total customers (key `'total_customers_card'`), `SummaryCard` pending activities (key `'pending_activities_card'`), `QuickActionButton` check-in (key `'checkin_action'`), `QuickActionButton` customers (key `'customers_action'`); register `BlocListener<CheckInBloc, CheckInState>` to dispatch `DashboardRefreshRequested` on `CheckedIn`/`CheckedOut`
    - Dispatch `LogoutRequested` on logout tap
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.9, 2.10, 2.11_

  - [ ]* 5.6 Write unit tests for `GetDashboardSummaryUseCase`
    - File: `test/features/dashboard/domain/usecases/get_dashboard_summary_usecase_test.dart`
    - _Requirements: 8.2_

  - [ ]* 5.7 Write BLoC tests for `DashboardBloc`
    - File: `test/features/dashboard/presentation/bloc/dashboard_bloc_test.dart`
    - Cover: initial state; emits `[DashboardLoading, DashboardLoaded]` on success; emits `[DashboardLoading, DashboardError]` when use case throws
    - _Requirements: 8.1, 8.5_

  - [ ]* 5.8 Write widget test for `DashboardScreen`
    - File: `test/widget/dashboard_screen_test.dart`
    - Provide mock `DashboardBloc` seeded with `DashboardLoaded`; assert screen renders and finds `total_customers_card`
    - _Requirements: 8.3_

- [ ] 6. Check-In feature — entity, repository interface, use cases, data layer, BLoC, screen
  - [ ] 6.1 Implement `CheckInRecord` entity
    - File: `lib/features/check_in/domain/entities/check_in_record.dart`
    - `CheckInRecord extends Equatable`; `checkInTime`, nullable `checkOutTime`; computed getters `checkInFormatted` and `checkOutFormatted` returning HH:mm strings; override `props`
    - _Requirements: 3.3, 3.5, 7.2_

  - [ ] 6.2 Implement `CheckInRepository` interface, `CheckInUseCase`, and `CheckOutUseCase`
    - File: `lib/features/check_in/domain/repositories/check_in_repository.dart`
    - File: `lib/features/check_in/domain/usecases/check_in_usecase.dart` — `Future<CheckInRecord> call()` sets check-in time to `DateTime.now()`
    - File: `lib/features/check_in/domain/usecases/check_out_usecase.dart` — `Future<CheckInRecord> call(CheckInRecord existing)` sets check-out time; throws `StateError` if `existing.checkOutTime != null`
    - _Requirements: 3.3, 3.5, 7.8_

  - [ ] 6.3 Implement `CheckInRepositoryImpl`
    - File: `lib/features/check_in/data/repositories/check_in_repository_impl.dart`
    - `checkIn()` creates a new `CheckInRecord` with `DateTime.now()` and assigns to `_source.todayCheckIn`; `checkOut()` returns a copy with `checkOutTime` set and updates `_source.todayCheckIn`
    - _Requirements: 3.3, 3.5, 3.7_

  - [ ] 6.4 Implement `CheckInBloc` with events and states
    - File: `lib/features/check_in/presentation/bloc/check_in_state.dart` — `NotCheckedIn`, `CheckedIn { CheckInRecord record }`, `CheckedOut { CheckInRecord record }`; include a transient `CheckInError { String message }` state that reverts to `NotCheckedIn`
    - File: `lib/features/check_in/presentation/bloc/check_in_event.dart` — `CheckInRequested`, `CheckOutRequested`
    - File: `lib/features/check_in/presentation/bloc/check_in_bloc.dart` — transition table from design; guard checkout-before-checkin by emitting `CheckInError` then `NotCheckedIn`
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.9_

  - [ ] 6.5 Implement `CheckInScreen`
    - File: `lib/features/check_in/presentation/screens/check_in_screen.dart`
    - `BlocBuilder<CheckInBloc, CheckInState>`; render `NotCheckedIn` / `CheckedIn` / `CheckedOut` views per design widget hierarchy with correct keys and disabled states; show error message when `CheckInError` state is emitted
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.8, 3.9_

  - [ ]* 6.6 Write unit tests for `CheckInUseCase` and `CheckOutUseCase`
    - File: `test/features/check_in/domain/usecases/check_in_usecase_test.dart`
    - File: `test/features/check_in/domain/usecases/check_out_usecase_test.dart`
    - _Requirements: 8.2_

  - [ ]* 6.7 Write BLoC tests for `CheckInBloc`
    - File: `test/features/check_in/presentation/bloc/check_in_bloc_test.dart`
    - Cover: initial state; `NotCheckedIn → CheckedIn`; `CheckedIn → CheckedOut`; checkout before checkin emits error then `NotCheckedIn`
    - _Requirements: 8.1, 8.5_

- [ ] 7. Customer feature — entity, repository interface, use cases, data layer, BLoC, list and detail screens
  - [ ] 7.1 Implement `Customer` entity
    - File: `lib/features/customer/domain/entities/customer.dart`
    - `Customer extends Equatable`; required: `id`, `fullName`, `companyName`; nullable: `email`, `phoneNumber`, `notes`; override `props`
    - _Requirements: 7.2_

  - [ ] 7.2 Implement `CustomerRepository` interface, `GetCustomersUseCase`, and `GetCustomerByIdUseCase`
    - File: `lib/features/customer/domain/repositories/customer_repository.dart`
    - File: `lib/features/customer/domain/usecases/get_customers_usecase.dart`
    - File: `lib/features/customer/domain/usecases/get_customer_by_id_usecase.dart`
    - Each `call()` delegates to the injected repository
    - _Requirements: 4.1, 4.5, 7.8_

  - [ ] 7.3 Implement `CustomerRepositoryImpl`
    - File: `lib/features/customer/data/repositories/customer_repository_impl.dart`
    - `getAllCustomers()` returns `List.unmodifiable(_source.customers)`; `getCustomerById()` does a linear search by `id`, returns `null` if not found
    - _Requirements: 4.1, 4.9_

  - [ ] 7.4 Implement `CustomerBloc` with events and states
    - File: `lib/features/customer/presentation/bloc/customer_state.dart` — `CustomerInitial`, `CustomerLoading`, `CustomerLoaded { allCustomers, displayedCustomers, searchQuery }`, `CustomerError { String message }`
    - File: `lib/features/customer/presentation/bloc/customer_event.dart` — `CustomerLoadRequested`, `CustomerSearchChanged { String query }`
    - File: `lib/features/customer/presentation/bloc/customer_bloc.dart` — on `CustomerSearchChanged` apply case-insensitive substring filter on `fullName` or `companyName` synchronously; on error emit `CustomerError`
    - _Requirements: 4.3, 4.4, 4.10_

  - [ ] 7.5 Implement `CustomerListScreen`
    - File: `lib/features/customer/presentation/screens/customer_list_screen.dart`
    - Per design widget hierarchy: search `TextField` (key `'customer_search'`), `ListView.builder` with `CustomerListItem` (key `'customer_item_$id'`), empty-state messages (keys `'no_match_message'` and `'empty_list_message'`)
    - Dispatch `CustomerSearchChanged` on search field change; `CustomerLoadRequested` on init
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.10, 4.11_

  - [ ] 7.6 Implement `CustomerDetailScreen`
    - File: `lib/features/customer/presentation/screens/customer_detail_screen.dart`
    - Accept `customerId` route parameter; display all fields (keys `'detail_full_name'`, `'detail_company'`, `'detail_email'`, `'detail_phone'`, `'detail_notes'`); show `'Not available'` placeholder for null optional fields; include `ActivitySummarySection` from `ActivityBloc`
    - _Requirements: 4.6, 4.7, 4.12, 4.13, 5.11_

  - [ ]* 7.7 Write unit tests for `GetCustomersUseCase`
    - File: `test/features/customer/domain/usecases/get_customers_usecase_test.dart`
    - _Requirements: 8.2_

  - [ ]* 7.8 Write BLoC tests for `CustomerBloc`
    - File: `test/features/customer/presentation/bloc/customer_bloc_test.dart`
    - Cover: initial state; loads customers; search filter narrows list; clearing search restores full list; handles error
    - _Requirements: 8.1, 8.5_

  - [ ]* 7.9 Write widget test for `CustomerListScreen`
    - File: `test/widget/customer_list_screen_test.dart`
    - Seed bloc with `CustomerLoaded`; assert screen renders and finds `customer_search`
    - _Requirements: 8.3_

- [ ] 8. Activity feature — entity, repository interface, use cases, data layer, BLoC, list and add screens
  - [ ] 8.1 Implement `Activity` entity and `ActivityStatus` enum
    - File: `lib/features/activity/domain/entities/activity.dart`
    - `enum ActivityStatus { pending, done }`; `Activity extends Equatable` with fields from the design; `copyWith({ActivityStatus? status})`; override `props`
    - _Requirements: 7.2_

  - [ ] 8.2 Implement `ActivityRepository` interface and three use cases
    - File: `lib/features/activity/domain/repositories/activity_repository.dart`
    - File: `lib/features/activity/domain/usecases/get_activities_usecase.dart`
    - File: `lib/features/activity/domain/usecases/add_activity_usecase.dart`
    - File: `lib/features/activity/domain/usecases/mark_activity_done_usecase.dart` — `markDone` throws `StateError` if already done
    - _Requirements: 5.1, 5.5, 5.7, 7.8_

  - [ ] 8.3 Implement `ActivityRepositoryImpl`
    - File: `lib/features/activity/data/repositories/activity_repository_impl.dart`
    - `addActivity()` appends to `_source.activities`; `markDone()` replaces the matching activity with a copy where `status = done`; `getAllActivities()` returns unmodifiable list
    - _Requirements: 5.5, 5.7, 5.9_

  - [ ] 8.4 Implement `ActivityBloc` with events and states
    - File: `lib/features/activity/presentation/bloc/activity_state.dart` — `ActivityInitial`, `ActivityLoading`, `ActivityLoaded { List<Activity> activities }`, `ActivityError { String message }`
    - File: `lib/features/activity/presentation/bloc/activity_event.dart` — `ActivityLoadRequested`, `ActivityAdded { Activity activity }`, `ActivityMarkedDone { String activityId }`
    - File: `lib/features/activity/presentation/bloc/activity_bloc.dart` — implement `_sortActivities()` pure helper (pending asc dueDate, then done asc dueDate); apply sort after every mutation; `try/catch` around all async calls
    - _Requirements: 5.7, 5.10_

  - [ ] 8.5 Implement `ActivityListScreen`
    - File: `lib/features/activity/presentation/screens/activity_list_screen.dart`
    - Per design widget hierarchy: `FloatingActionButton` (key `'add_activity_button'`), `ActivityListItem` (key `'activity_item_$id'`); done items show strikethrough + checkmark; pending items show `IconButton` mark-done (key `'mark_done_$id'`); dispatch `ActivityMarkedDone` on tap; display due date in DD/MM/YYYY via `intl`
    - _Requirements: 5.1, 5.2, 5.7, 5.8, 5.10_

  - [ ] 8.6 Implement `AddActivityScreen` with validation
    - File: `lib/features/activity/presentation/screens/add_activity_screen.dart`
    - `StatefulWidget` with `Form`; `TextFormField` title (key `'activity_title'`, maxLength 100 display), `DatePickerField` (key `'activity_due_date'`, min today), `DropdownButtonFormField` customer (key `'activity_customer_selector'`); validate via `ActivityValidator` on submit; show field-level errors within 100 ms; on success dispatch `ActivityAdded` and pop
    - _Requirements: 5.3, 5.4, 5.5, 5.6, 6.5, 6.6, 6.7, 6.8, 6.10, 6.11_

  - [ ]* 8.7 Write unit tests for `AddActivityUseCase` and `MarkActivityDoneUseCase`
    - File: `test/features/activity/domain/usecases/add_activity_usecase_test.dart`
    - File: `test/features/activity/domain/usecases/mark_activity_done_usecase_test.dart`
    - _Requirements: 8.2_

  - [ ]* 8.8 Write BLoC tests for `ActivityBloc`
    - File: `test/features/activity/presentation/bloc/activity_bloc_test.dart`
    - Cover: initial state; `ActivityLoadRequested` → `[loading, loaded]`; `ActivityAdded` appends and re-sorts; `ActivityMarkedDone` changes status to done; error propagation
    - _Requirements: 8.1, 8.5_

- [ ] 9. Checkpoint — ensure all unit and widget tests pass
  - Ensure all tests pass with `flutter test test/features/ test/widget/`, ask the user if questions arise.

- [ ] 10. Router and DI wiring — complete `AppRouter`, `ServiceLocator.setup()`, and `main.dart`
  - [ ] 10.1 Complete `AppRouter` with auth guard and all screen builders
    - File: `lib/core/router/app_router.dart`
    - Implement `GoRouterRefreshStream` adapter; complete `_guard` redirect logic; wire all six routes to their real screen widgets; customer detail route uses path parameter `/:id`
    - _Requirements: 1.1, 1.4, 1.8, 2.6, 2.7, 7.9_

  - [ ] 10.2 Complete `ServiceLocator.setup()` wiring all dependencies
    - File: `lib/core/di/service_locator.dart`
    - Instantiate `MockDataSource`, all repository implementations, all use cases, and all BLoCs in the order defined in the design
    - _Requirements: 7.1_

  - [ ] 10.3 Wire `main.dart` with `MultiBlocProvider` and `MaterialApp.router`
    - File: `lib/main.dart`
    - Call `ServiceLocator.instance.setup()`; build `AppRouter(sl.authBloc).router`; wrap with `MultiBlocProvider` using `BlocProvider.value` for all five BLoCs; use `MaterialApp.router`
    - _Requirements: 7.4_

- [ ] 11. Property-based tests — six correctness properties from the design
  - [ ] 11.1 Write property test for Property 1: BLoC state idempotence
    - File: `test/features/auth/presentation/bloc/auth_bloc_property_test.dart`
    - Use a property-based testing library (e.g., `dart_test_property` or manual parametric test loop for ≥ 100 cases); for each BLoC, emit a stabilising event twice and assert the resulting state equals the state after the first emission (via `equatable ==`)
    - Tag comment: `// Feature: mobile-test-ai-poc, Property 1: BLoC state idempotence`
    - _Requirements: 8.9_

  - [ ] 11.2 Write property test for Property 2: session isolation
    - File: `test/features/mock_data/mock_data_source_property_test.dart`
    - Simulate session events (check-in, add activity, authenticate), then construct a fresh `MockDataSource` and fresh BLoC instances; assert each BLoC initial state equals its defined constant and no prior-session data is present
    - Tag comment: `// Feature: mobile-test-ai-poc, Property 2: Session isolation`
    - _Requirements: 3.7, 5.9_

  - [ ] 11.3 Write property test for Property 3: customer search filter round-trip
    - File: `test/features/customer/presentation/bloc/customer_bloc_property_test.dart`
    - For ≥ 100 generated query strings: (a) every item in filtered result contains `q` case-insensitively; (b) every matching item from full list appears in result; (c) empty query returns full list
    - Tag comment: `// Feature: mobile-test-ai-poc, Property 3: Customer search filter round-trip`
    - _Requirements: 4.3, 4.4, 4.10_

  - [ ] 11.4 Write property test for Property 4: activity sort order invariant
    - File: `test/features/activity/presentation/bloc/activity_bloc_property_test.dart`
    - For ≥ 100 randomly ordered activity lists: assert all pending items precede all done items; within each group items are ordered by `dueDate` ascending
    - Tag comment: `// Feature: mobile-test-ai-poc, Property 4: Activity sort order invariant`
    - _Requirements: 5.10_

  - [ ] 11.5 Write property test for Property 5: activity title display truncation
    - File: `test/features/activity/domain/usecases/add_activity_usecase_property_test.dart`
    - For ≥ 100 titles of random length 1–200 chars: rendered list-item text ≤ 100 chars; first 100 chars match when truncated; underlying `Activity.title` is unchanged
    - Tag comment: `// Feature: mobile-test-ai-poc, Property 5: Activity title display truncation`
    - _Requirements: 5.2_

  - [ ] 11.6 Write property test for Property 6: dashboard summary count derivation
    - File: `test/features/dashboard/domain/usecases/get_dashboard_summary_usecase_property_test.dart`
    - For ≥ 100 generated customer and activity list combinations: `totalCustomers == customers.length`; `pendingActivities == count of activities where status == pending && dueDate <= today`
    - Tag comment: `// Feature: mobile-test-ai-poc, Property 6: Dashboard summary count derivation`
    - _Requirements: 2.3, 2.4_

- [ ] 12. Kiro steering files
  - [ ] 12.1 Create `flutter-architecture.md` steering file
    - File: `.kiro/steering/flutter-architecture.md`
    - Three rules: (1) layer dependency constraints with positive/negative examples, (2) folder naming convention with examples, (3) class naming conventions with examples — content verbatim from the design's Kiro Tooling Design section
    - _Requirements: 9.1, 9.4_

  - [ ] 12.2 Create `bloc-conventions.md` steering file
    - File: `.kiro/steering/bloc-conventions.md`
    - Three rules: (1) BLoC naming patterns, (2) event/state structure, (3) BLoC testing patterns — each with positive and negative examples
    - _Requirements: 9.2, 9.4_

  - [ ] 12.3 Create `testing-standards.md` steering file
    - File: `.kiro/steering/testing-standards.md`
    - Three rules: (1) test file location convention, (2) `bloc_test`/`mocktail` usage, (3) 80% coverage target — each with positive and negative examples
    - _Requirements: 9.3, 9.4_

- [ ] 13. Kiro custom agents
  - [ ] 13.1 Create `flutter-dev.md` agent definition
    - File: `.kiro/agents/flutter-dev.md`
    - Include steering file paths `.kiro/steering/flutter-architecture.md` and `.kiro/steering/bloc-conventions.md`; `includeFiles: lib/**/*.dart`; out-of-scope response instruction per requirement 10.5
    - _Requirements: 10.1, 10.4, 10.5, 9.5_

  - [ ] 13.2 Create `qa-agent.md` agent definition
    - File: `.kiro/agents/qa-agent.md`
    - Include steering file path `.kiro/steering/testing-standards.md`; `includeFiles: test/**/*.dart`; out-of-scope response instruction
    - _Requirements: 10.2, 10.4, 10.5, 9.5_

  - [ ] 13.3 Create `code-review-agent.md` agent definition
    - File: `.kiro/agents/code-review-agent.md`
    - Include all three steering file paths; `includeFiles: **/*.dart`; violation report format `VIOLATION [rule-id] in <file>:<line>: <desc>`; non-.dart file response instruction
    - _Requirements: 10.3, 10.4, 10.5, 9.5_

- [ ] 14. Kiro agent hooks
  - [ ] 14.1 Create `dart-format.json` hook
    - File: `.kiro/hooks/dart-format.json`
    - `PostFileSave` trigger; matcher `\.dart$`; command `dart format --output=none --set-exit-if-changed "$KIRO_FILE_PATH"`
    - _Requirements: 11.1, 11.4, 11.5_

  - [ ] 14.2 Create `flutter-analyze.json` hook
    - File: `.kiro/hooks/flutter-analyze.json`
    - `PostFileSave` trigger; matcher `\.dart$`; command `flutter analyze --no-fatal-warnings "$KIRO_FILE_PATH"`
    - _Requirements: 11.2, 11.4, 11.5_

  - [ ] 14.3 Create `run-tests-on-save.json` hook
    - File: `.kiro/hooks/run-tests-on-save.json`
    - `PostFileSave` trigger; matcher `lib/features/.+/(presentation/bloc|domain/usecases)/.+\.dart$`; bash command that derives mirrored test path, checks file existence, and runs `flutter test <test-path>` or logs "No test file found"
    - _Requirements: 11.3, 11.4, 11.5_

- [ ] 15. Integration test — happy-path login-to-dashboard flow
  - [ ] 15.1 Implement the happy-path integration test
    - File: `test/integration_test/happy_path_test.dart`
    - `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`; pump full app via `app.main()`; enter `demo@example.com` in `email_field`; enter `password123` in `password_field`; tap `login_button`; `pumpAndSettle()`; assert `find.byKey(const Key('total_customers_card'))` finds one widget
    - _Requirements: 8.4_

- [ ] 16. Final checkpoint — full test suite passes
  - Run `flutter test` (unit + widget tests) and verify no failures; run `flutter analyze` and confirm zero errors; ask the user if questions arise before submitting.

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP; they implement tests and Kiro tooling showcase items (tasks 12–14 are optional by nature)
- All property-based tests (task 11) use a minimum of 100 iterations; use `dart_test_property`, `fast_check`, or a manual parametric loop — whichever is available in the project's dependency set
- The `simulateError` flag on `MockDataSource` is used exclusively by BLoC and widget tests to trigger error states; it is never `true` in production code paths
- Each task references specific requirements for full traceability
- The integration test (task 15) requires a connected device or simulator; it is excluded from the standard `flutter test` run and executed with `flutter test test/integration_test/happy_path_test.dart`
- Checkpoints (tasks 9 and 16) ensure incremental validation at feature-complete milestones

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3"] },
    { "id": 1, "tasks": ["2.1", "2.2", "2.3", "2.4"] },
    { "id": 2, "tasks": ["3.1"] },
    { "id": 3, "tasks": ["3.2", "4.1"] },
    { "id": 4, "tasks": ["4.2", "4.3"] },
    { "id": 5, "tasks": ["4.4"] },
    { "id": 6, "tasks": ["4.5", "4.6", "5.1"] },
    { "id": 7, "tasks": ["4.7", "4.8", "5.2", "5.3", "6.1"] },
    { "id": 8, "tasks": ["5.4", "5.6", "6.2", "6.3"] },
    { "id": 9, "tasks": ["5.5", "5.7", "5.8", "6.4", "7.1"] },
    { "id": 10, "tasks": ["6.5", "6.6", "6.7", "7.2", "7.3", "8.1"] },
    { "id": 11, "tasks": ["7.4", "7.7", "8.2", "8.3"] },
    { "id": 12, "tasks": ["7.5", "7.8", "7.9", "8.4"] },
    { "id": 13, "tasks": ["7.6", "8.5", "8.6", "8.7", "8.8"] },
    { "id": 14, "tasks": ["10.1", "10.2"] },
    { "id": 15, "tasks": ["10.3"] },
    { "id": 16, "tasks": ["11.1", "11.2", "11.3", "11.4", "11.5", "11.6"] },
    { "id": 17, "tasks": ["12.1", "12.2", "12.3"] },
    { "id": 18, "tasks": ["13.1", "13.2", "13.3"] },
    { "id": 19, "tasks": ["14.1", "14.2", "14.3"] },
    { "id": 20, "tasks": ["15.1"] }
  ]
}
```
