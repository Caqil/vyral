import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_button.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Google Login
        CustomButton(
          text: 'Continue with Google',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Google login coming soon!'),
              ),
            );
          },
          type: ButtonType.outline,
          isFullWidth: true,
          icon: Icons.g_mobiledata_rounded,
        ),

        const SizedBox(height: 12),

        // Apple Login (iOS only)
        if (Theme.of(context).platform == TargetPlatform.iOS) ...[
          CustomButton(
            text: 'Continue with Apple',
            onPressed: () {
              // TODO: Implement Apple login
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Apple login coming soon!'),
                ),
              );
            },
            type: ButtonType.outline,
            isFullWidth: true,
            icon: Icons.phone_iphone_rounded,
            backgroundColor: colorScheme.onSurface,
            textColor: colorScheme.surface,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
