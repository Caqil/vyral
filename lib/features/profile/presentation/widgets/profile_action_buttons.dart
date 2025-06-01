// lib/features/profile/presentation/widgets/profile_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/follow_status_entity.dart';

class ProfileActionButtons extends StatefulWidget {
  final UserEntity user;
  final bool isOwnProfile;
  final FollowStatusEntity? followStatus;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onMessagePressed;
  final VoidCallback? onEditPressed;

  const ProfileActionButtons({
    super.key,
    required this.user,
    required this.isOwnProfile,
    this.followStatus,
    this.onFollowPressed,
    this.onMessagePressed,
    this.onEditPressed,
  });

  @override
  State<ProfileActionButtons> createState() => _ProfileActionButtonsState();
}

class _ProfileActionButtonsState extends State<ProfileActionButtons>
    with TickerProviderStateMixin {
  late AnimationController _followAnimationController;
  late Animation<double> _followScaleAnimation;
  late Animation<Color?> _followColorAnimation;

  bool _isFollowLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _followAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _followScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _followAnimationController,
      curve: Curves.easeInOut,
    ));

    _followColorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(_followAnimationController);
  }

  @override
  void dispose() {
    _followAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    if (widget.isOwnProfile) {
      return _buildOwnProfileActions(colorScheme, theme);
    } else {
      return _buildOtherProfileActions(colorScheme, theme);
    }
  }

  Widget _buildOwnProfileActions(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Row(
      children: [
        // Edit Profile Button
        Expanded(
          flex: 2,
          child: ShadButton.outline(
            onPressed: widget.onEditPressed,
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.pen, size: 16),
                SizedBox(width: 8),
                Text('Edit Profile'),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Share Profile Button
        ShadButton.outline(
          onPressed: _handleShareProfile,
          child: const Icon(LucideIcons.share),
        ),

        const SizedBox(width: 8),

        // More Options Button
        ShadButton.ghost(
          onPressed: _handleMoreOptions,
          child:  Icon(LucideIcons.menu),
        ),
      ],
    );
  }

  Widget _buildOtherProfileActions(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Row(
      children: [
        // Follow/Unfollow Button
        Expanded(
          flex: 2,
          child: AnimatedBuilder(
            animation: _followAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _followScaleAnimation.value,
                child: _buildFollowButton(colorScheme, theme),
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        // Message Button
        ShadButton.outline(
          onPressed: widget.onMessagePressed,
          child: const Icon(LucideIcons.messageCircle),
        ),

        const SizedBox(width: 8),

        // More Options Button
        ShadButton.ghost(
          onPressed: _handleMoreOptions,
          child:  Icon(LucideIcons.menu),
        ),
      ],
    );
  }

  Widget _buildFollowButton(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    final followStatus = widget.followStatus;
    final isFollowing = followStatus?.isFollowing ?? false;
    final isPending = followStatus?.isPending ?? false;
    final isBlocked = followStatus?.isBlocked ?? false;

    if (isBlocked) {
      return ShadButton.destructive(
        onPressed: null,
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

    if (isPending) {
      return ShadButton.outline(
        onPressed: _handleFollowAction,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isFollowLoading) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),
            ] else ...[
              const Icon(LucideIcons.clock, size: 16),
            ],
            const SizedBox(width: 8),
            const Text('Pending'),
          ],
        ),
      );
    }

    if (isFollowing) {
      return _buildFollowingButton(colorScheme, theme);
    } else {
      return _buildFollowButton2(colorScheme, theme);
    }
  }

  Widget _buildFollowingButton(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return MouseRegion(
      onEnter: (_) => _followAnimationController.forward(),
      onExit: (_) => _followAnimationController.reverse(),
      child: ShadButton.secondary(
        onPressed: _handleFollowAction,
        child: AnimatedBuilder(
          animation: _followAnimationController,
          builder: (context, child) {
            final isHovered = _followAnimationController.value > 0.5;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isFollowLoading) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.secondaryForeground,
                      ),
                    ),
                  ),
                ] else ...[
                  Icon(
                    isHovered ? LucideIcons.userMinus : LucideIcons.userCheck,
                    size: 16,
                    color: isHovered ? Colors.red : null,
                  ),
                ],
                const SizedBox(width: 8),
                Text(
                  isHovered ? 'Unfollow' : 'Following',
                  style: TextStyle(
                    color: isHovered ? Colors.red : null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFollowButton2(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return ShadButton.secondary(
      onPressed: _handleFollowAction,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isFollowLoading) ...[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.primaryForeground,
                ),
              ),
            ),
          ] else ...[
            const Icon(LucideIcons.userPlus, size: 16),
          ],
          const SizedBox(width: 8),
          const Text('Follow'),
        ],
      ),
    );
  }

  void _handleFollowAction() async {
    if (_isFollowLoading) return;

    setState(() => _isFollowLoading = true);

    // Add haptic feedback
    // HapticFeedback.lightImpact();

    try {
      await Future.delayed(
          const Duration(milliseconds: 300)); // Simulate API call
      widget.onFollowPressed?.call();
    } finally {
      if (mounted) {
        setState(() => _isFollowLoading = false);
      }
    }
  }

  void _handleShareProfile() {
    showShadSheet(
      context: context,
      builder: (context) => ShadSheet(
        title: const Text('Share Profile'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.copy),
              title: const Text('Copy Profile Link'),
              onTap: () {
                Navigator.pop(context);
                _copyProfileLink();
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.qrCode),
              title: const Text('Show QR Code'),
              onTap: () {
                Navigator.pop(context);
                _showQRCode();
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.share2),
              title: const Text('Share via...'),
              onTap: () {
                Navigator.pop(context);
                _shareViaSystem();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleMoreOptions() {
    showShadSheet(
      context: context,
      builder: (context) => ShadSheet(
        title: Text(widget.isOwnProfile ? 'Profile Options' : 'User Options'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.isOwnProfile) ...[
              ListTile(
                leading: const Icon(LucideIcons.flag),
                title: const Text('Report User'),
                onTap: () {
                  Navigator.pop(context);
                  _reportUser();
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.userX),
                title: const Text('Block User'),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser();
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.volumeX),
                title: const Text('Mute User'),
                onTap: () {
                  Navigator.pop(context);
                  _muteUser();
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(LucideIcons.settings),
                title: const Text('Privacy Settings'),
                onTap: () {
                  Navigator.pop(context);
                  _openPrivacySettings();
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.eye),
                title: const Text('View as Others'),
                onTap: () {
                  Navigator.pop(context);
                  _viewAsOthers();
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.download),
                title: const Text('Download Data'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadData();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _copyProfileLink() {
    // Copy profile link to clipboard
    context.showSuccessSnackBar('Profile link copied to clipboard');
  }

  void _showQRCode() {
    // Show QR code for profile
  }

  void _shareViaSystem() {
    // Share via system share sheet
  }

  void _reportUser() {
    // Show report dialog
  }

  void _blockUser() {
    // Show block confirmation dialog
  }

  void _muteUser() {
    // Show mute confirmation dialog
  }

  void _openPrivacySettings() {
    // Navigate to privacy settings
  }

  void _viewAsOthers() {
    // Show profile as others see it
  }

  void _downloadData() {
    // Initiate data download
  }
}
