// lib/features/profile/presentation/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/avatar_widget.dart';

class ProfileHeader extends StatefulWidget {
  final UserEntity user;
  final String? coverImageUrl;
  final bool isOwnProfile;

  const ProfileHeader({
    super.key,
    required this.user,
    this.coverImageUrl,
    required this.isOwnProfile,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Cover Image Section
              _buildCoverImage(colorScheme),

              // Profile Info Section
              Transform.translate(
                offset: const Offset(0, -40),
                child: _buildProfileInfo(colorScheme, theme),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoverImage(ShadColorScheme colorScheme) {
    const double coverHeight = 200.0;

    return Container(
      height: coverHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.8),
            colorScheme.secondary.withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Cover Image
          if (widget.coverImageUrl != null)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.coverImageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colorScheme.muted,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withOpacity(0.8),
                        colorScheme.secondary.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),

          // Edit Cover Button (for own profile)
          if (widget.isOwnProfile)
            Positioned(
              top: 16,
              right: 16,
              child: ShadButton.ghost(
                onPressed: _handleEditCover,
                size: ShadButtonSize.sm,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    LucideIcons.camera,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Profile Picture
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildProfilePicture(colorScheme),
              ),

              const Spacer(),

              // Verification Badge & Status
              if (widget.user.isVerified || widget.user.isVerified)
                _buildBadges(colorScheme),
            ],
          ),

          const SizedBox(height: 16),

          // Name and Username
          _buildNameSection(colorScheme, theme),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(ShadColorScheme colorScheme) {
    const double size = 120.0;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.background,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: widget.user.profilePicture != null
                ? CachedNetworkImage(
                    imageUrl: widget.user.profilePicture!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: colorScheme.muted,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => AvatarWidget(
                      name: widget.user.displayName ?? widget.user.username,
                      size: size - 8,
                    ),
                  )
                : AvatarWidget(
                    name: widget.user.displayName ?? widget.user.username,
                    size: size - 8,
                  ),
          ),
        ),

        // Edit Profile Picture Button (for own profile)
        if (widget.isOwnProfile)
          Positioned(
            bottom: 0,
            right: 0,
            child: ShadButton.ghost(
              onPressed: _handleEditProfilePicture,
              size: ShadButtonSize.sm,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.background,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.camera,
                  color: colorScheme.primaryForeground,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBadges(ShadColorScheme colorScheme) {
    return Row(
      children: [
        if (widget.user.isVerified)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              LucideIcons.badgeCheck,
              color: colorScheme.primaryForeground,
              size: 16,
            ),
          ),
        if (widget.user.isPremium) ...[
          if (widget.user.isVerified) const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.crown,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNameSection(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display Name
        Row(
          children: [
            Expanded(
              child: Text(
                widget.user.displayName ?? widget.user.username,
                style: theme.textTheme.h3?.copyWith(
                  color: colorScheme.foreground,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Username
        Text(
          '@${widget.user.username}',
          style: theme.textTheme.large?.copyWith(
            color: colorScheme.mutedForeground,
          ),
        ),

        // User Status/Activity
        const SizedBox(height: 8),
        _buildUserStatus(colorScheme, theme),
      ],
    );
  }

  Widget _buildUserStatus(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Row(
      children: [
        // Online Status Indicator
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.user.isActive ? Colors.green : colorScheme.muted,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 8),

        Text(
          widget.user.isActive ? 'Active now' : 'Last seen recently',
          style: theme.textTheme.small?.copyWith(
            color: colorScheme.mutedForeground,
          ),
        ),

        const Spacer(),

        // Join Date
        Text(
          'Joined ${widget.user.createdAt.displayDate}',
          style: theme.textTheme.small?.copyWith(
            color: colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }

  void _handleEditCover() {
    // Show cover image picker
    showShadSheet(
      context: context,
      builder: (context) => ShadSheet(
        title: const Text('Change Cover Photo'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // Handle camera
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // Handle gallery
              },
            ),
            if (widget.coverImageUrl != null)
              ListTile(
                leading: const Icon(LucideIcons.trash2),
                title: const Text('Remove Cover Photo'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle remove
                },
              ),
          ],
        ),
      ),
    );
  }

  void _handleEditProfilePicture() {
    // Show profile picture picker
    showShadSheet(
      context: context,
      builder: (context) => ShadSheet(
        title: const Text('Change Profile Picture'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // Handle camera
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // Handle gallery
              },
            ),
            if (widget.user.profilePicture != null)
              ListTile(
                leading: const Icon(LucideIcons.trash2),
                title: const Text('Remove Profile Picture'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle remove
                },
              ),
          ],
        ),
      ),
    );
  }
}
