import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/app/app.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';

import '../../../../core/widgets/avatar_widget.dart';

class UserListItem extends StatelessWidget {
  final UserEntity user;
  final Function(UserEntity) onUserPressed;
  final Function(UserEntity)? onFollowPressed;
  final Function(UserEntity)? onMessagePressed;
  final bool showFollowButton;
  final bool showMessageButton;

  const UserListItem({
    super.key,
    required this.user,
    required this.onUserPressed,
    this.onFollowPressed,
    this.onMessagePressed,
    this.showFollowButton = true,
    this.showMessageButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: GestureDetector(
          onTap: () => onUserPressed(user),
          child: Stack(
            children: [
              AvatarWidget(
                imageUrl: user.profilePicture,
                name: user.displayName ?? user.username,
                size: 48,
              ),
              if (user.isActive)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.background,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        title: GestureDetector(
          onTap: () => onUserPressed(user),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  user.displayName ?? user.username,
                  style: theme.textTheme.list.copyWith(
                    color: colorScheme.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (user.isVerified) ...[
                const SizedBox(width: 4),
                Icon(
                  LucideIcons.badgeCheck,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ],
              if (user.isPremium) ...[
                const SizedBox(width: 4),
                const Icon(
                  LucideIcons.crown,
                  size: 16,
                  color: Color(0xFFFFD700),
                ),
              ],
            ],
          ),
        ),
        subtitle: GestureDetector(
          onTap: () => onUserPressed(user),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${user.username}',
                style: theme.textTheme.small.copyWith(
                  color: colorScheme.mutedForeground,
                ),
              ),
              if (user.bio != null) ...[
                const SizedBox(height: 4),
                Text(
                  user.bio!,
                  style: theme.textTheme.small.copyWith(
                    color: colorScheme.foreground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${user.followersCount} followers',
                    style: theme.textTheme.small.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${user.postsCount} posts',
                    style: theme.textTheme.small.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showMessageButton && onMessagePressed != null) ...[
              ShadButton.ghost(
                onPressed: () => onMessagePressed!(user),
                size: ShadButtonSize.sm,
                child: const Icon(LucideIcons.messageCircle, size: 16),
              ),
              const SizedBox(width: 8),
            ],
            if (showFollowButton && onFollowPressed != null)
              ShadButton.outline(
                onPressed: () => onFollowPressed!(user),
                size: ShadButtonSize.sm,
                child: const Text('Follow'),
              ),
          ],
        ),
      ),
    );
  }
}
