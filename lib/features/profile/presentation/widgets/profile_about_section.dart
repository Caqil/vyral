import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/core/utils/extensions.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';

class ProfileAboutSection extends StatelessWidget {
  final UserEntity user;

  const ProfileAboutSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information
          _buildSection(
            'Personal Information',
            [
              if (user.firstName != null && user.lastName != null)
                _buildInfoItem(
                  LucideIcons.user,
                  'Full Name',
                  '${user.firstName} ${user.lastName}',
                  colorScheme,
                  theme,
                ),
              if (user.email.isNotEmpty)
                _buildInfoItem(
                  LucideIcons.mail,
                  'Email',
                  user.email,
                  colorScheme,
                  theme,
                ),
              if (user.phone != null)
                _buildInfoItem(
                  LucideIcons.phone,
                  'Phone',
                  user.phone!,
                  colorScheme,
                  theme,
                ),
              if (user.dateOfBirth != null)
                _buildInfoItem(
                  LucideIcons.calendar,
                  'Date of Birth',
                  user.dateOfBirth!.displayDate,
                  colorScheme,
                  theme,
                ),
              if (user.gender != null)
                _buildInfoItem(
                  LucideIcons.user,
                  'Gender',
                  user.gender!.capitalize,
                  colorScheme,
                  theme,
                ),
            ],
            colorScheme,
            theme,
          ),

          const SizedBox(height: 24),

          // Contact Information
          if (user.website != null ||
              user.location != null ||
              user.socialLinks != null)
            _buildSection(
              'Contact Information',
              [
                if (user.website != null)
                  _buildInfoItem(
                    LucideIcons.globe,
                    'Website',
                    user.website!,
                    colorScheme,
                    theme,
                    isLink: true,
                  ),
                if (user.location != null)
                  _buildInfoItem(
                    LucideIcons.mapPin,
                    'Location',
                    user.location!,
                    colorScheme,
                    theme,
                  ),
                if (user.socialLinks != null)
                  ...user.socialLinks!.entries.map(
                    (entry) => _buildInfoItem(
                      _getSocialIcon(entry.key),
                      entry.key.capitalizeWords,
                      entry.value,
                      colorScheme,
                      theme,
                      isLink: true,
                    ),
                  ),
              ],
              colorScheme,
              theme,
            ),

          const SizedBox(height: 24),

          // Account Information
          _buildSection(
            'Account Information',
            [
              _buildInfoItem(
                LucideIcons.calendar,
                'Joined',
                user.createdAt.displayDate,
                colorScheme,
                theme,
              ),
              _buildInfoItem(
                LucideIcons.shield,
                'Account Status',
                user.isVerified ? 'Verified' : 'Unverified',
                colorScheme,
                theme,
                statusColor: user.isVerified ? Colors.green : null,
              ),
              _buildInfoItem(
                LucideIcons.eye,
                'Profile Visibility',
                user.isPrivate ? 'Private' : 'Public',
                colorScheme,
                theme,
                statusColor: user.isPrivate ? Colors.orange : Colors.green,
              ),
              if (user.isPremium)
                _buildInfoItem(
                  LucideIcons.crown,
                  'Membership',
                  'Premium',
                  colorScheme,
                  theme,
                  statusColor: const Color(0xFFFFD700),
                ),
            ],
            colorScheme,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Widget> items,
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.h4.copyWith(
              color: colorScheme.foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: item,
              )),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    ShadColorScheme colorScheme,
    ShadThemeData theme, {
    bool isLink = false,
    Color? statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.mutedForeground,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.small.copyWith(
                  color: colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.p.copyWith(
                  color: statusColor ??
                      (isLink ? colorScheme.primary : colorScheme.foreground),
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'twitter':
      case 'x':
        return LucideIcons.twitter;
      case 'instagram':
        return LucideIcons.instagram;
      case 'linkedin':
        return LucideIcons.linkedin;
      case 'facebook':
        return LucideIcons.facebook;
      case 'youtube':
        return LucideIcons.youtube;
      case 'github':
        return LucideIcons.github;
      default:
        return LucideIcons.link;
    }
  }
}
