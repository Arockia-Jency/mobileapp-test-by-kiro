# Requirements Document

## Introduction

MobileTestAI is a Kiro Frontier Development proof-of-concept Flutter application that demonstrates Kiro IDE's AI-assisted development capabilities while delivering a fully working employee field-management app. The app covers six features — authentication, an employee dashboard, check-in/check-out, customer listing and details, follow-up activity management, and cross-cutting input validation — built with Clean Architecture, BLoC state management, and local mock data only. No backend, database, or network calls are required. The spec also captures the Kiro tooling requirements: steering files, custom agents, agent hooks, and automated testing workflows that illustrate spec-driven development from requirements through implementation.

---

## Glossary

- **App**: The MobileTestAI Flutter application.
- **User**: An employee who uses the App on a mobile or desktop device.
- **AuthBloc**: The BLoC responsible for authentication state and transitions.
- **DashboardBloc**: The BLoC responsible for aggregating and exposing dashboard summary data.
- **CheckInBloc**: The BLoC responsible for managing check-in and check-out state within a session.
- **CustomerBloc**: The BLoC responsible for loading and filtering the customer list.
- **ActivityBloc**: The BLoC responsible for creating, listing, and completing follow-up activities.
- **MockDataSource**: The in-memory data layer that provides hardcoded demo data for all features.
- **Navigator**: The go_router-based routing component that controls screen transitions.
- **Session**: The in-memory lifecycle from app launch to app process termination; no data persists across restarts.
- **BLoC**: Business Logic Component — a reactive state-management pattern using streams of events and states.
- **UseCase**: A domain-layer class that encapsulates a single piece of business logic and is called by a BLoC.
- **Entity**: An immutable domain model object (e.g., Customer, Activity, Employee).
- **Steering File**: A Kiro configuration file that encodes architecture and coding conventions the AI agent follows.
- **Agent Hook**: A Kiro automation that fires on a file-system or editor event and executes a command or agent prompt.
- **Custom Agent**: A Kiro agent profile configured to specialise in a particular development or QA role.

---

## Requirements

### Requirement 1: Demo Authentication

**User Story:** As a User, I want to log in with demo credentials so that I can access the app's protected features.

#### Acceptance Criteria

1. IF no authenticated session exists in memory, THEN THE App SHALL display the Login Screen as the initial route on launch.
2. THE Login Screen SHALL contain an email input field accepting up to 254 characters, a password input field accepting up to 128 characters, and a submit button.
3. WHEN the User submits the login form with the email `demo@example.com` and password `password123`, THE AuthBloc SHALL transition to an Authenticated state.
4. WHEN the AuthBloc transitions to Authenticated, THE Navigator SHALL route the User to the Dashboard Screen.
5. WHEN the User submits the login form with any email or password combination that does not match the accepted demo credentials, THE AuthBloc SHALL transition to an AuthenticationFailed state containing a descriptive error message.
6. WHEN the AuthBloc is in AuthenticationFailed state, THE Login Screen SHALL display the error message below the submit button.
7. WHILE the AuthBloc is in an AuthenticatingInProgress state, THE Login Screen SHALL disable the submit button and display a loading indicator.
8. WHEN the User navigates back to the Login Screen while already Authenticated, THE Navigator SHALL redirect the User to the Dashboard Screen.
9. THE AuthBloc SHALL expose exactly four states: Unauthenticated, AuthenticatingInProgress, Authenticated, and AuthenticationFailed.
10. IF the User submits the login form with the email field empty, the password field empty, or both fields empty, THEN THE Login Screen SHALL display an error message indicating that all fields are required and SHALL NOT transition the AuthBloc out of the Unauthenticated state.

---

### Requirement 2: Employee Dashboard

**User Story:** As an authenticated User, I want to see a summary dashboard so that I can quickly understand my current status and workload.

#### Acceptance Criteria

1. WHEN the AuthBloc state is Authenticated, THE Dashboard Screen SHALL be accessible as the home route.
2. THE Dashboard Screen SHALL display a check-in status card showing whether the User has checked in today, reflecting the most recent check-in event recorded in the MockDataSource for the current calendar date.
3. THE Dashboard Screen SHALL display a summary card showing the total count of customers assigned to the User, where the count is a non-negative integer derived from the MockDataSource.
4. THE Dashboard Screen SHALL display a summary card showing the count of pending follow-up activities for the User, where "pending" means activities with a due date on or before the current date that have not been marked as complete in the MockDataSource.
5. THE Dashboard Screen SHALL display a quick-action area containing exactly the two actions "Check In / Check Out" and "View Customers", each rendered as a tappable widget.
6. WHEN the User taps the "Check In / Check Out" quick action, THE Navigator SHALL route the User to the Check-In Screen.
7. WHEN the User taps the "View Customers" quick action, THE Navigator SHALL route the User to the Customer List Screen.
8. THE DashboardBloc SHALL derive all displayed counts from the MockDataSource without making network calls.
9. WHEN the DashboardBloc requests data from the MockDataSource and the MockDataSource returns an error, THEN THE Dashboard Screen SHALL display an error message indicating that data could not be loaded, and the previously displayed counts SHALL be cleared.
10. WHEN the User taps the logout action on the Dashboard Screen, THE AuthBloc SHALL transition to the Unauthenticated state and THE Navigator SHALL route the User to the Login Screen, discarding the Dashboard Screen from the navigation stack.
11. WHEN the Dashboard Screen is first rendered after the AuthBloc state becomes Authenticated, THE DashboardBloc SHALL load all summary data from the MockDataSource within 2 seconds and display it before showing any summary card values.

---

### Requirement 3: Employee Check-In and Check-Out

**User Story:** As an authenticated User, I want to record my daily check-in and check-out times so that my attendance is tracked for the session.

#### Acceptance Criteria

1. WHILE the CheckInBloc state is NotCheckedIn, THE Check-In Screen SHALL display the status label "Not Checked In".
2. WHEN the CheckInBloc state is NotCheckedIn, THE Check-In Screen SHALL display a "Check In" button.
3. WHEN the User taps the "Check In" button, THE CheckInBloc SHALL record the check-in timestamp as the device local time in HH:mm format and transition to CheckedIn state.
4. WHEN the CheckInBloc state is CheckedIn, THE Check-In Screen SHALL display the recorded check-in time in HH:mm format and a "Check Out" button.
5. WHEN the User taps the "Check Out" button, THE CheckInBloc SHALL record the check-out timestamp as the device local time in HH:mm format and transition to CheckedOut state.
6. WHEN the CheckInBloc state is CheckedOut, THE Check-In Screen SHALL display both the check-in time and check-out time in HH:mm format and SHALL disable the "Check In" and "Check Out" buttons for the remainder of the app session.
7. THE CheckInBloc SHALL store check-in and check-out timestamps in memory only; THE App SHALL not persist these values after the app process is terminated.
8. WHEN the CheckInBloc state changes, THE DashboardBloc SHALL update the Dashboard Screen to display the current check-in status label and, if checked in or checked out, the recorded check-in time, without requiring user interaction.
9. IF the User attempts to check out before checking in, THEN THE CheckInBloc SHALL remain in NotCheckedIn state and THE Check-In Screen SHALL display an error message indicating that check-in must be completed before checking out.

---

### Requirement 4: Customer Listing and Details

**User Story:** As an authenticated User, I want to browse a list of customers and view their profiles so that I can access contact information and notes before a visit.

#### Acceptance Criteria

1. THE Customer List Screen SHALL display a scrollable list of all customers provided by the MockDataSource.
2. EACH customer list item SHALL display at minimum the customer's full name and company name.
3. THE Customer List Screen SHALL display a search input that filters the visible list to customers whose full name or company name contains the search text, case-insensitively.
4. WHEN the User clears the search input, THE Customer List Screen SHALL display the full unfiltered customer list.
5. WHEN the User taps a customer list item, THE Navigator SHALL route the User to the Customer Detail Screen for that customer.
6. THE Customer Detail Screen SHALL display the customer's full name, company name, email address, phone number, and notes.
7. THE Customer Detail Screen SHALL display a list of follow-up activities linked to that customer, showing each activity's title, due date, and status.
8. THE CustomerBloc SHALL load customer data from the MockDataSource without making network calls.
9. THE MockDataSource SHALL provide at minimum ten distinct customer records with realistic mock data.
10. WHEN the customer list is empty after filtering, THE Customer List Screen SHALL display a message indicating no customers match the search.
11. IF the MockDataSource returns an empty customer list on initial load, THEN THE Customer List Screen SHALL display a message indicating no customers are available.
12. WHEN the User taps the back navigation control on the Customer Detail Screen, THE Navigator SHALL return the User to the Customer List Screen with the previous search input and scroll position preserved.
13. IF a customer record is missing one or more optional fields (email address, phone number, or notes), THEN THE Customer Detail Screen SHALL display a placeholder text indicating the field is not available for each missing field.

---

### Requirement 5: Follow-Up Activity Management

**User Story:** As an authenticated User, I want to create and manage follow-up activities for customers so that I can track outstanding tasks.

#### Acceptance Criteria

1. THE App SHALL provide a Follow-Up Activity List Screen displaying all activities across all customers.
2. EACH activity list item SHALL display the activity title (truncated at 100 characters), the linked customer name, the due date in DD/MM/YYYY format, and the status as either "Pending" or "Done".
3. WHEN the User taps the "Add Activity" button on the Follow-Up Activity List Screen, THE App SHALL display an Add Activity form.
4. THE Add Activity form SHALL contain a title input field accepting up to 100 characters, a due date picker accepting any calendar date on or after the current date, and a customer selector listing all customers currently stored in the in-memory customer list.
5. WHEN the User submits the Add Activity form with a non-empty title, a valid due date, and a selected customer, THE ActivityBloc SHALL add the new activity with status set to Pending to the in-memory activity list and close the form within 1 second.
6. WHEN the User submits the Add Activity form with a missing title, a missing due date, or no customer selected, THE App SHALL display a field-level validation error message directly below each invalid field and SHALL NOT add the activity to the in-memory list.
7. WHEN the User taps the "Mark Done" action on a Pending activity, THE ActivityBloc SHALL update that activity's status to Done and reflect the change on the Follow-Up Activity List Screen within 1 second.
8. WHEN an activity's status is Done, THE App SHALL display that activity list item with a strikethrough on the title text and a checkmark icon, distinguishing it from Pending activity items which display neither.
9. THE ActivityBloc SHALL store all activities in memory only; THE App SHALL NOT persist activities across Session restarts.
10. THE Follow-Up Activity List Screen SHALL display all Pending activities ordered by due date ascending, followed by all Done activities ordered by due date ascending, by default without any user interaction.
11. WHEN the User navigates to the Customer Detail Screen, THE App SHALL display the current Pending and Done activity counts for that customer sourced directly from the ActivityBloc's in-memory list without requiring the User to navigate away and back.

---

### Requirement 6: Input Validation and Error Handling

**User Story:** As a User, I want clear validation feedback on all forms so that I can correct mistakes and understand what the app requires.

#### Acceptance Criteria

1. THE Login Screen SHALL validate that the email input is non-empty and matches a standard email format (local-part@domain.tld, where local-part is 1–64 characters and domain is 1–255 characters) before submitting.
2. THE Login Screen SHALL validate that the password input contains at minimum 6 characters and at most 128 characters before submitting.
3. WHEN a validation rule is violated, THE App SHALL display an error message adjacent to the offending field within 100 milliseconds of the submission attempt.
4. WHEN all field-level validation rules pass, THE App SHALL proceed with the form submission action.
5. THE Add Activity form SHALL validate that the title input is non-empty and contains at most 200 characters.
6. THE Add Activity form SHALL validate that a due date has been selected and the selected date is not before the current calendar date.
7. THE Add Activity form SHALL validate that a customer has been selected from the customer selector.
8. IF an unexpected error occurs in any BLoC, THEN THE App SHALL emit an error state and THE relevant screen SHALL display a user-readable error message without crashing, preserving all previously entered field values.
9. THE App SHALL not display raw exception stack traces or internal error codes to the User.
10. WHEN the User corrects a previously invalid field and resubmits, THE App SHALL clear the prior error message for that field before displaying the result of the new submission attempt.
11. IF any required field in the Add Activity form is empty or invalid at submission, THEN THE App SHALL display an error message adjacent to each offending field and SHALL NOT proceed with form submission.

---

### Requirement 7: Clean Architecture and BLoC Structure

**User Story:** As a developer, I want the codebase organised in Clean Architecture layers with feature-based folders so that each feature is independently maintainable and testable.

#### Acceptance Criteria

1. THE App SHALL organise source code under `lib/features/<feature>/` with sub-folders: `domain/`, `data/`, and `presentation/`.
2. THE `domain/` layer SHALL contain Entities, UseCase classes, and repository interfaces; it SHALL have no import of any `package:flutter` library or any package other than `package:equatable`.
3. THE `data/` layer SHALL contain MockDataSource implementations and repository implementation classes; it SHALL import only from the `domain/` layer, Dart core libraries, and `package:mocktail` (permitted solely for MockDataSource definitions).
4. THE `presentation/` layer SHALL contain BLoC classes, event and state definitions, and widget files; it SHALL depend on the `domain/` layer and `flutter_bloc`.
5. THE App SHALL declare the following packages in `pubspec.yaml`: `flutter_bloc ^9.x`, `equatable ^2.x`, `go_router ^14.x`, and `intl ^0.19.x` as runtime dependencies.
6. THE App SHALL declare `mocktail ^1.x` and `bloc_test ^10.x` as dev dependencies.
7. EACH BLoC class SHALL extend `Bloc<Event, State>` from `flutter_bloc` and SHALL define its event and state classes in separate files.
8. EACH UseCase class SHALL expose a single `call()` method and SHALL be instantiable and executable in a plain Dart test file that imports only `package:test` and `package:mocktail`, with no call to `flutter_test`'s `testWidgets` or `pumpWidget`.
9. THE Navigator SHALL be implemented using `go_router` and SHALL define all named routes in a single routing configuration file under `lib/core/router/`.

---

### Requirement 8: Testing Coverage

**User Story:** As a developer, I want automated tests for BLoCs, use-cases, and key screens so that regressions are caught before release.

#### Acceptance Criteria

1. THE App SHALL provide unit tests for every BLoC covering at minimum the happy-path event sequence and one failure event sequence per BLoC.
2. THE App SHALL provide unit tests for every UseCase covering at minimum one valid input and at minimum one invalid or boundary input per UseCase.
3. THE App SHALL provide widget tests for the Login Screen, the Dashboard Screen, and the Customer List Screen; each widget test SHALL assert that the screen renders without throwing an exception and that at minimum one key widget specific to that screen is present in the widget tree.
4. THE App SHALL provide an integration test that covers the happy-path flow: app launch → login with the demo credentials (email: `demo@example.com`, password: `password123`) → Dashboard Screen visible, verified by finding a widget whose key or text uniquely identifies the Dashboard Screen.
5. WHEN unit tests for a BLoC are run, THE test suite SHALL use `bloc_test` helpers to assert state sequences.
6. WHEN UseCase unit tests require a repository dependency, THE test SHALL use `mocktail` to provide a mock repository.
7. THE test file for each feature SHALL be located at `test/features/<feature>/` mirroring the `lib/features/<feature>/` structure.
8. THE App SHALL achieve at minimum 80% line coverage across all BLoC and UseCase files, measurable by running `flutter test --coverage`.
9. FOR ALL BLoC state transitions, emitting an event and then emitting the same event again when already in the resulting state SHALL produce a final state that compares equal to the state produced by the first emission, where equality is determined by the `==` operator as implemented via `equatable`.

---

### Requirement 9: Kiro Steering Files

**User Story:** As a developer using Kiro IDE, I want steering files that encode the project's architecture and coding conventions so that AI agents generate consistent, standards-compliant code.

#### Acceptance Criteria

1. THE project SHALL include a steering file at `.kiro/steering/flutter-architecture.md` defining the Clean Architecture layer rules, folder structure, and naming conventions for this project; this file SHALL define at minimum three distinct rules covering layer dependency constraints, folder naming, and class naming.
2. THE project SHALL include a steering file at `.kiro/steering/bloc-conventions.md` defining BLoC naming patterns, event/state naming patterns, and BLoC testing patterns; this file SHALL define at minimum three distinct rules, one per topic listed.
3. THE project SHALL include a steering file at `.kiro/steering/testing-standards.md` defining the test file location convention, the use of `bloc_test` and `mocktail`, and the minimum line coverage expectation of 80% across BLoC and UseCase files.
4. EACH steering file SHALL include at minimum one positive example and one negative example for each rule it defines.
5. EACH custom agent definition and agent hook definition that relies on a steering file SHALL include the relative path to that steering file in its instructions block so that the steering file is explicitly loaded when the agent or hook is invoked.

---

### Requirement 10: Kiro Custom Agents

**User Story:** As a developer, I want custom Kiro agents for specific development roles so that AI assistance is focused and consistent.

#### Acceptance Criteria

1. THE project SHALL define a `flutter-dev` custom agent whose instructions include the relative paths to the architecture and BLoC conventions steering files, and whose `includeFiles` or equivalent scope field lists `lib/**/*.dart` as the target file pattern.
2. THE project SHALL define a `qa-agent` custom agent whose instructions include the relative path to the testing-standards steering file, and whose `includeFiles` or equivalent scope field lists `test/**/*.dart` as the target file pattern.
3. THE project SHALL define a `code-review-agent` custom agent whose scope covers all `.dart` files in the repository and whose instructions specify that each identified convention violation SHALL be reported as a comment citing the specific rule in the relevant steering file and the file location of the violation.
4. EACH custom agent definition SHALL be stored as a Markdown file under `.kiro/agents/`.
5. WHEN a custom agent is invoked for a file outside its defined `includeFiles` pattern, THE agent instructions SHALL instruct it to respond with a message naming the appropriate agent for that file type and take no further action.

---

### Requirement 11: Kiro Agent Hooks

**User Story:** As a developer, I want agent hooks that automate formatting and test execution on file-save so that code quality is maintained continuously.

#### Acceptance Criteria

1. THE project SHALL define an agent hook that runs `dart format` on any saved `.dart` file and outputs the result of the format check, including any lines that were reformatted, to the hook's output channel visible in the IDE.
2. THE project SHALL define an agent hook that runs `flutter analyze` after any `.dart` file is saved and outputs each analysis error or warning, including its file path and line number, to the hook's output channel visible in the IDE.
3. WHEN a BLoC or UseCase `.dart` source file is saved and a corresponding test file exists at the mirrored path under `test/features/`, THE hook SHALL run that test file using `flutter test <path-to-test-file>` and output the test results to the hook's output channel.
4. EACH agent hook definition SHALL be stored under `.kiro/hooks/` in the format required by Kiro's hook configuration schema.
5. WHEN an agent hook command exits with a non-zero exit code, THE hook SHALL write the full command output to the hook's output channel and complete without preventing the file save from succeeding.
