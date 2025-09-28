import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../utils/app_router.dart';
import '../widgets/zen_button.dart';
import '../widgets/zen_input_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  String? _formError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final controller = ref.read(authControllerProvider.notifier);

    try {
      await controller.register(email: email, password: password);
      final state = ref.read(authControllerProvider);
      if (state is Authenticated) {
        if (!mounted) return;
        context.go(AppRoutes.home);
      } else if (state is AuthError) {
        setState(() {
          _formError = state.exception.message;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.exception.message)),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = _isSubmitting || authState is AuthLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create your ZenScreen account',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock personalized insights and cloud sync.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ZenInputField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) {
                        if (_formError != null) {
                          setState(() {
                            _formError = null;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required.';
                        }
                        final emailRegex =
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ZenInputField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'At least 8 characters, 1 number, 1 letter',
                      obscureText: true,
                      onChanged: (_) {
                        if (_formError != null) {
                          setState(() {
                            _formError = null;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required.';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters.';
                        }
                        final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
                        final hasNumber = RegExp(r'[0-9]').hasMatch(value);
                        if (!hasLetter || !hasNumber) {
                          return 'Include at least one letter and one number.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ZenInputField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      obscureText: true,
                      onChanged: (_) {
                        if (_formError != null) {
                          setState(() {
                            _formError = null;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password.';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),
                    if (_formError != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _formError!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    ZenButton.primary(
                      isLoading ? 'Creating Account...' : 'Create Account',
                      onPressed: isLoading ? null : _handleSubmit,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed:
                          isLoading ? null : () => context.go(AppRoutes.login),
                      child: const Text('Already have an account? Sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

