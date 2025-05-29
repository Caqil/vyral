// lib/features/auth/presentation/widgets/login_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'social_login_buttons.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == true) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          emailOrUsername: _emailController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email/Username field
          CustomTextField(
            controller: _emailController,
            label: 'Email or Username',
            hint: 'Enter your email or username',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.person_outline),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email or username is required';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Password field
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            obscureText: true,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.lock_outline),
            validator: Validators.validateRequired,
            onSubmitted: (_) => _handleSubmit(),
          ),
          
          const SizedBox(height: 16),
          
          // Remember me and Forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) => setState(() => _rememberMe = value ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    'Remember me',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go(RouteNames.forgotPassword),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Login button
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return CustomButton(
                text: 'Sign In',
                onPressed: _handleSubmit,
                isLoading: state.isLoading,
                isFullWidth: true,
                icon: Icons.login_rounded,
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Divider
          Row(
            children: [
              Expanded(
                child: Divider(color: colorScheme.outline.withOpacity(0.5)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: colorScheme.outline.withOpacity(0.5)),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Social login buttons
          const SocialLoginButtons(),
        ],
      ),
    );
  }
}

