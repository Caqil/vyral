import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/extensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyEmailPage extends StatefulWidget {
  final String token;

  const VerifyEmailPage({
    super.key,
    required this.token,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  void initState() {
    super.initState();
    // Automatically verify email when page loads
    if (widget.token.isNotEmpty) {
      context.read<AuthBloc>().add(
            AuthVerifyEmailRequested(token: widget.token),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Verify Email',
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            context.showSuccessSnackBar(state.successMessage!);
          } else if (state.errorMessage != null) {
            context.showErrorSnackBar(state.errorMessage!);
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state.successMessage != null) {
                        return Icon(
                          Icons.check_circle_rounded,
                          size: 50,
                          color: colorScheme.primary,
                        );
                      } else if (state.errorMessage != null) {
                        return Icon(
                          Icons.error_rounded,
                          size: 50,
                          color: colorScheme.error,
                        );
                      } else {
                        return Icon(
                          Icons.email_rounded,
                          size: 50,
                          color: colorScheme.onPrimaryContainer,
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Title and message
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    String title = 'Verifying Email';
                    String message =
                        'Please wait while we verify your email address...';

                    if (state.successMessage != null) {
                      title = 'Email Verified!';
                      message =
                          'Your email has been successfully verified. You can now access all features.';
                    } else if (state.errorMessage != null) {
                      title = 'Verification Failed';
                      message =
                          'We couldn\'t verify your email. The link may be expired or invalid.';
                    } else if (widget.token.isEmpty) {
                      title = 'Invalid Link';
                      message = 'The verification link is invalid or missing.';
                    }

                    return Column(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Action buttons
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state.successMessage != null) {
                      return CustomButton(
                        text: 'Continue to App',
                        onPressed: () => context.go(RouteNames.login),
                        isFullWidth: true,
                        icon: Icons.arrow_forward_rounded,
                      );
                    } else if (state.errorMessage != null ||
                        widget.token.isEmpty) {
                      return Column(
                        children: [
                          if (widget.token.isNotEmpty) ...[
                            CustomButton(
                              text: 'Try Again',
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                      AuthVerifyEmailRequested(
                                          token: widget.token),
                                    );
                              },
                              isFullWidth: true,
                              icon: Icons.refresh_rounded,
                            ),
                            const SizedBox(height: 16),
                          ],
                          CustomButton(
                            text: 'Back to Login',
                            onPressed: () => context.go(RouteNames.login),
                            type: ButtonType.outline,
                            isFullWidth: true,
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
