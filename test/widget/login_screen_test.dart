import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobile_test_ai/features/auth/presentation/screens/login_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  testWidgets('LoginScreen renders email field, password field, and submit button',
      (tester) async {
    final mockBloc = MockAuthBloc();
    when(() => mockBloc.state).thenReturn(const Unauthenticated());

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: mockBloc,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.byKey(const Key('email_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });

  testWidgets('LoginScreen shows error text when AuthenticationFailed',
      (tester) async {
    final mockBloc = MockAuthBloc();
    when(() => mockBloc.state).thenReturn(
      const AuthenticationFailed('Invalid email or password.'),
    );

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: mockBloc,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.byKey(const Key('auth_error')), findsOneWidget);
  });

  testWidgets('LoginScreen shows loading indicator when AuthenticatingInProgress',
      (tester) async {
    final mockBloc = MockAuthBloc();
    when(() => mockBloc.state).thenReturn(const AuthenticatingInProgress());

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: mockBloc,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
