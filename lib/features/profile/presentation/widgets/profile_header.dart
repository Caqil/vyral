// lib/features/profile/presentation/widgets/profile_header.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/core/utils/extensions.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../domain/entities/user_entity.dart';

class ProfileHeader extends StatelessWidget {
  final UserEntity user;
  final String? coverImageUrl;
  final bool isOwnProfile;
  final bool isPrivateView;
  final VoidCallback? onCoverTap;
  final VoidCallback? onProfilePictureTap;

  const ProfileHeader({
    super.key,
    required this.user,
    this.coverImageUrl,
    required this.isOwnProfile,
    this.isPrivateView = false,
    this.onCoverTap,
    this.onProfilePictureTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Photo
          _buildCoverPhoto(context, colorScheme),

          // Profile Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture (overlapping cover)
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: _buildProfilePicture(context, colorScheme),
                ),

                // Name and Username
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: _buildNameSection(context, colorScheme, theme),
                ),

                // Bio and details (only for public profiles or own profile)
                if (!isPrivateView || isOwnProfile) ...[
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: _buildBioSection(context, colorScheme, theme),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPhoto(BuildContext context, ShadColorScheme colorScheme) {
    final displayCoverUrl = isPrivateView && !isOwnProfile
        ? null
        : (coverImageUrl ?? user.coverPicture);

    return GestureDetector(
      onTap: onCoverTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.muted,
          image: displayCoverUrl != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(displayCoverUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: displayCoverUrl == null
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withOpacity(0.3),
                      colorScheme.secondary.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    isPrivateView ? LucideIcons.lock : LucideIcons.image,
                    size: 48,
                    color: colorScheme.mutedForeground.withOpacity(0.5),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildProfilePicture(
      BuildContext context, ShadColorScheme colorScheme) {
    return Row(
      children: [
        GestureDetector(
          onTap: onProfilePictureTap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.background,
                width: 4,
              ),
            ),
            child: AvatarWidget(
              imageUrl:
                  isPrivateView && !isOwnProfile ? null : user.profilePicture,
              name: user.displayName ?? user.username,
              size: 80,
              showPrivateIcon: isPrivateView && !isOwnProfile,
            ),
          ),
        ),
        const Spacer(),
        if (isOwnProfile)
          ShadButton.outline(
            onPressed: onCoverTap,
            size: ShadButtonSize.sm,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.camera, size: 14),
                SizedBox(width: 4),
                Text('Edit'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNameSection(
      BuildContext context, ShadColorScheme colorScheme, ShadThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                user.displayName ?? user.username,
                style: theme.textTheme.h3.copyWith(
                  color: colorScheme.foreground,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.isVerified) ...[
              const SizedBox(width: 8),
              Icon(
                LucideIcons.badgeCheck,
                size: 24,
                color: colorScheme.primary,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '@${user.username}',
          style: theme.textTheme.large.copyWith(
            color: colorScheme.mutedForeground,
          ),
        ),
        if (user.isPremium) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.crown,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Premium',
                  style: theme.textTheme.small.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBioSection(
      BuildContext context, ShadColorScheme colorScheme, ShadThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.bio != null && user.bio!.isNotEmpty) ...[
          Text(
            user.bio!,
            style: theme.textTheme.p.copyWith(
              color: colorScheme.foreground,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
        ],

        // Additional info
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            if (user.location != null)
              _buildInfoItem(
                LucideIcons.mapPin,
                user.location!,
                colorScheme,
                theme,
              ),
            if (user.website != null)
              _buildInfoItem(
                LucideIcons.globe,
                user.website!,
                colorScheme,
                theme,
                isLink: true,
              ),
            _buildInfoItem(
              LucideIcons.calendar,
              'Joined ${user.createdAt.displayDate}',
              colorScheme,
              theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String text,
    ShadColorScheme colorScheme,
    ShadThemeData theme, {
    bool isLink = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.mutedForeground,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.small.copyWith(
              color: isLink ? colorScheme.primary : colorScheme.foreground,
              decoration: isLink ? TextDecoration.underline : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
