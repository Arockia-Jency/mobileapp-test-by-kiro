import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_test_ai/core/validation/email_validator.dart';
import 'package:mobile_test_ai/core/validation/password_validator.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final emailError = EmailValidator.validate(_emailController.text);
    final passwordError = PasswordValidator.validate(_passwordController.text);

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    if (emailError != null || passwordError != null) return;

    context.read<AuthBloc>().add(
          LoginSubmitted(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                // Clear field errors when retrying after failure
                if (state is AuthenticationFailed) {
                  setState(() {
                    _emailError = null;
                    _passwordError = null;
                  });
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthenticatingInProgress;

                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'MobileTestAI',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        key: const Key('email_field'),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 254,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          errorText: _emailError,
                          border: const OutlineInputBorder(),
                          counterText: '',
                        ),
                        onChanged: (_) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('password_field'),
                        controller: _passwordController,
                        obscureText: true,
                        maxLength: 128,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorText: _passwordError,
                          border: const OutlineInputBorder(),
                          counterText: '',
                        ),
                        onChanged: (_) {
                          if (_passwordError != null) {
                            setState(() => _passwordError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        key: const Key('login_button'),
                        onPressed: isLoading ? null : () => _submit(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Sign In'),
                      ),
                      if (state is AuthenticationFailed) ...[
                        const SizedBox(height: 16),
                        Text(
                          key: const Key('auth_error'),
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
