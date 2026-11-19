---
inclusion: always
---

# Flutter Architecture Steering — MobileTestAI

This file defines the Clean Architecture conventions for the MobileTestAI project. All AI agents must follow these rules when generating or modifying Dart source files.

---

## Rule 1: Layer Dependency Constraints

The dependency rule is strict and unidirectional:

```
Presentation  →  Domain  ←  Data
```

- **Domain layer** (`lib/features/<feature>/domain/`) MUST NOT import any Flutter package, `flutter_bloc`, or any file from the `data/` or `presentation/` layers.
- **Data layer** (`lib/features/<feature>/data/`) MAY import from `domain/` and Dart core libraries only.
- **Presentation layer** (`lib/features/<feature>/presentation/`) MAY import from `domain/` and `flutter_bloc` only.
- `lib/core/` utilities may be imported by `presentation/` but NEVER by `domain/`.

✅ **GOOD** — a domain entity importing only equatable:
```dart
// lib/features/auth/domain/entities/employee.dart
import 'package:equatable/equatable.dart';
class Employee extends Equatable { ... }
```

❌ **BAD** — a domain entity importing Flutter:
```dart
// lib/features/auth/domain/entities/employee.dart
import 'package:flutter/material.dart'; // VIOLATION
class Employee extends StatelessWidget { ... }
```

---

## Rule 2: Folder Naming Convention

- Feature folders under `lib/features/` use `snake_case`.
- Sub-folders are always named exactly: `domain/`, `data/`, `presentation/`.
- Further sub-folders: `entities/`, `repositories/`, `usecases/` (domain); `repositories/` (data); `bloc/`, `screens/` (presentation).

✅ **GOOD**:
```
lib/features/check_in/domain/entities/check_in_record.dart
lib/features/check_in/presentation/bloc/check_in_bloc.dart
```

❌ **BAD** — PascalCase folder or missing layer:
```
lib/features/CheckIn/Domain/entities/CheckInRecord.dart
lib/features/check_in/check_in_bloc.dart
```

---

## Rule 3: Class Naming Conventions

| Artefact | Naming pattern | Example |
|---|---|---|
| Entity | `PascalCase` noun, no suffix | `Employee`, `Customer`, `Activity` |
| Repository interface | `<Feature>Repository` (abstract class) | `AuthRepository` |
| Repository impl | `<Feature>RepositoryImpl` | `AuthRepositoryImpl` |
| UseCase | `<Verb><Noun>UseCase` | `LoginUseCase`, `MarkActivityDoneUseCase` |
| BLoC | `<Feature>Bloc` | `AuthBloc`, `DashboardBloc` |
| BLoC events | `<Feature>Event` base + imperative concrete | `AuthEvent`, `LoginSubmitted` |
| BLoC states | `<Feature>State` base + noun/adjective concrete | `AuthState`, `Authenticated` |

✅ **GOOD**:
```dart
class GetCustomersUseCase { Future<List<Customer>> call() ... }
```

❌ **BAD** — service suffix or verb-only name:
```dart
class CustomerService { ... }  // VIOLATION — not a UseCase
class FetchCustomers { ... }   // VIOLATION — missing UseCase suffix
```
