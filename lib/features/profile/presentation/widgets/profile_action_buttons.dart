// lib/features/profile/presentation/widgets/profile_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/core/utils/extensions.dart';
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

    // If no follow status loaded yet, show default follow button
    if (followStatus == null) {
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

    // Handle different follow states
    if (followStatus!.isPending) {
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

    if (followStatus!.isFollowing) {
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

    if (followStatus!.isBlocked) {
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

    // Default follow button
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

  bool get _canMessage {
    if (isPrivateView) return false;
    if (followStatus == null) return !user.isPrivate;
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
                _shareProfile(context);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.copy),
              title: const Text('Copy Profile Link'),
              onTap: () {
                Navigator.pop(context);
                _copyProfileLink(context);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.qrCode),
              title: const Text('QR Code'),
              onTap: () {
                Navigator.pop(context);
                _showQRCode(context);
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
                _shareProfile(context);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.copy),
              title: const Text('Copy Profile Link'),
              onTap: () {
                Navigator.pop(context);
                _copyProfileLink(context);
              },
            ),
            const Divider(),
            if (followStatus?.isFollowing == true)
              ListTile(
                leading: const Icon(LucideIcons.bellOff),
                title: const Text('Mute Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  _muteUser(context);
                },
              ),
            ListTile(
              leading: const Icon(LucideIcons.flag),
              title: const Text('Report User'),
              onTap: () {
                Navigator.pop(context);
                _reportUser(context);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.userX, color: Colors.red),
              title:
                  const Text('Block User', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _blockUser(context);
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
          ShadButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Add unblock functionality
            },
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }

  void _shareProfile(BuildContext context) {
    // Implement profile sharing
    context.showSuccessSnackBar(context, 'Profile link shared!');
  }

  void _copyProfileLink(BuildContext context) {
    // Implement copy profile link
    context.showSuccessSnackBar(context, 'Profile link copied!');
  }

  void _showQRCode(BuildContext context) {
    // Implement QR code display
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Profile QR Code'),
        description:
            const Text('Others can scan this QR code to view your profile'),
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Text('QR Code Placeholder'),
          ),
        ),
      ),
    );
  }

  void _muteUser(BuildContext context) {
    // Implement mute user
    context.showSuccessSnackBar(context, 'User muted');
  }

  void _reportUser(BuildContext context) {
    // Implement report user
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Report User'),
        description: const Text('Why are you reporting this user?'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Spam'),
              onTap: () {
                Navigator.pop(context);
                context.showSuccessSnackBar(context, 'User reported for spam');
              },
            ),
            ListTile(
              title: const Text('Harassment'),
              onTap: () {
                Navigator.pop(context);
                context.showSuccessSnackBar(
                    context, 'User reported for harassment');
              },
            ),
            ListTile(
              title: const Text('Inappropriate content'),
              onTap: () {
                Navigator.pop(context);
                context.showSuccessSnackBar(
                    context, 'User reported for inappropriate content');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _blockUser(BuildContext context) {
    // Implement block user
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Block User'),
        description: Text('Are you sure you want to block @${user.username}?'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () {
              Navigator.pop(context);
              context.showSuccessSnackBar(context, 'User blocked');
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}
