// lib/features/profile/presentation/widgets/profile_action_buttons.dart
// ✅ QUICK FIX: Add this temporary mock while debugging the API issue

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/core/utils/extensions.dart';
import 'package:vyral/core/utils/logger.dart';
import '../../domain/entities/follow_status_entity.dart';
import '../../domain/entities/user_entity.dart';

class ProfileActionButtons extends StatelessWidget {
  final UserEntity user;
  final bool isOwnProfile;
  final FollowStatusEntity? followStatus;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onMessagePressed;
  final VoidCallback? onEditPressed;
  final bool isPrivateView;
  final bool isFollowLoading;

  const ProfileActionButtons({
    super.key,
    required this.user,
    required this.isOwnProfile,
    this.followStatus,
    this.onFollowPressed,
    this.onMessagePressed,
    this.onEditPressed,
    this.isPrivateView = false,
    this.isFollowLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    if (isOwnProfile) {
      return _buildOwnProfileButtons(context, colorScheme);
    } else {
      return _buildOtherProfileButtons(context, colorScheme);
    }
  }

  Widget _buildOtherProfileButtons(
      BuildContext context, ShadColorScheme colorScheme) {
    return Row(
      children: [
        // Follow/Following Button
        Expanded(
          flex: 2,
          child: _buildFollowButton(context, colorScheme),
        ),

        const SizedBox(width: 12),

        // Message Button
        if (_canMessage) ...[
          Expanded(
            child: ShadButton.outline(
              onPressed: onMessagePressed,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.messageCircle, size: 16),
                  SizedBox(width: 8),
                  Text('Message'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],

        // More Options Button
        ShadButton.outline(
          onPressed: () => _showUserOptions(context),
          child: const Icon(LucideIcons.menu),
        ),
      ],
    );
  }

  Widget _buildFollowButton(BuildContext context, ShadColorScheme colorScheme) {
    // ✅ TEMPORARY DEBUG: Show what's happening
    AppLogger.debug('🔍 ProfileActionButtons _buildFollowButton:');
    AppLogger.debug('   - isFollowLoading: $isFollowLoading');
    AppLogger.debug('   - followStatus == null: ${followStatus == null}');
    AppLogger.debug('   - isOwnProfile: $isOwnProfile');

    // PRIORITY 1: Show loading state
    if (isFollowLoading) {
      return ShadButton.outline(
        onPressed: null,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Loading...'),
          ],
        ),
      );
    }

    // ✅ QUICK FIX: If followStatus is null, create a temporary default one
    FollowStatusEntity effectiveFollowStatus;

    if (followStatus == null) {
      AppLogger.debug('⚠️ followStatus is NULL - creating temporary default');

      // Create a temporary default follow status
      effectiveFollowStatus = FollowStatusEntity(
        userId: 'current_user', // Mock current user ID
        targetUserId: user.id,
        isFollowing: false, // Default to not following
        isFollowedBy: false,
        isPending: false,
        isBlocked: false,
        isMuted: false,
        followedAt: null,
        updatedAt: DateTime.now(),
      );

      AppLogger.debug('✅ Created temporary follow status: isFollowing=false');
    } else {
      effectiveFollowStatus = followStatus!;
      AppLogger.debug(
          '✅ Using existing follow status: isFollowing=${followStatus!.isFollowing}');
    }

    // Handle different follow states
    if (effectiveFollowStatus.isBlocked) {
      return ShadButton.destructive(
        onPressed: () => _showBlockedUserDialog(context),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.userX, size: 16),
            SizedBox(width: 8),
            Text('Blocked'),
          ],
        ),
      );
    }

    if (effectiveFollowStatus.isPending) {
      return ShadButton.outline(
        onPressed: onFollowPressed,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.clock, size: 16),
            SizedBox(width: 8),
            Text('Requested'),
          ],
        ),
      );
    }

    if (effectiveFollowStatus.isFollowing) {
      return ShadButton.outline(
        onPressed: onFollowPressed,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.userCheck, size: 16),
            SizedBox(width: 8),
            Text('Following'),
          ],
        ),
      );
    }

    // Default: Not following
    return ShadButton(
      onPressed: onFollowPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.userPlus, size: 16),
          const SizedBox(width: 8),
          Text(user.isPrivate ? 'Request' : 'Follow'),
        ],
      ),
    );
  }

  Widget _buildOwnProfileButtons(
      BuildContext context, ShadColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: ShadButton(
            onPressed: onEditPressed,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.settings, size: 16),
                SizedBox(width: 8),
                Text('Edit Profile'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        ShadButton.outline(
          onPressed: () => _showProfileOptions(context),
          child: const Icon(LucideIcons.share),
        ),
      ],
    );
  }

  bool get _canMessage {
    if (isPrivateView) return false;
    if (followStatus == null) return !user.isPrivate; // Default behavior
    return followStatus!.canMessage;
  }

  void _showProfileOptions(BuildContext context) {
    showShadSheet(
      context: context,
      builder: (context) => ShadSheet(
        title: const Text('Profile Options'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.share),
              title: const Text('Share Profile'),
              onTap: () {
                Navigator.pop(context);
                context.showSuccessSnackBar(context, 'Profile shared!');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUserOptions(BuildContext context) {
    showShadSheet(
      context: context,
      builder: (context) => ShadSheet(
        title: const Text('User Options'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.share),
              title: const Text('Share Profile'),
              onTap: () {
                Navigator.pop(context);
                context.showSuccessSnackBar(context, 'Profile shared!');
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.flag),
              title: const Text('Report User'),
              onTap: () {
                Navigator.pop(context);
                context.showSuccessSnackBar(context, 'User reported');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockedUserDialog(BuildContext context) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('User Blocked'),
        description: Text(
            'You have blocked @${user.username}. You cannot follow or message them until you unblock them.'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
