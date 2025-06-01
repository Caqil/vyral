import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == true) {
      context.read<AuthBloc>().add(
            AuthForgotPasswordRequested(email: _emailController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Forgot Password',
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            context.showSuccessSnackBar(state.successMessage!);
            context.pop();
          } else if (state.errorMessage != null) {
            context.showErrorSnackBar(state.errorMessage!);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        size: 40,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title and description
                  Text(
                    'Reset Password',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email address and we\'ll send you a link to reset your password.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Email field
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    placeholder: Text('Enter your email'),
                    keyboardType: TextInputType.emailAddress,
                    prefix: const Icon(Icons.email_outlined),
                    validator: Validators.validateEmail,
                   onTap: () => _handleSubmit(),
                  ),

                  const SizedBox(height: 32),

                  // Submit button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Send Reset Link',
                        onPressed: _handleSubmit,
                        isLoading: state.isLoading,
                        isFullWidth: true,
                        icon: Icons.send_rounded,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Back to login
                  Center(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Back to Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
