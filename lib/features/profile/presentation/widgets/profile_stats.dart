// lib/features/profile/presentation/widgets/profile_stats.dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/user_stats_entity.dart';

class ProfileStats extends StatefulWidget {
  final UserEntity user;
  final UserStatsEntity? stats;
  final Function(String) onStatsPressed;

  const ProfileStats({
    super.key,
    required this.user,
    this.stats,
    required this.onStatsPressed,
  });

  @override
  State<ProfileStats> createState() => _ProfileStatsState();
}

class _ProfileStatsState extends State<ProfileStats>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );

    _animations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.elasticOut,
        ),
      );
    }).toList();
  }

  void _startAnimations() {
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _animationControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.border),
        boxShadow: [
          BoxShadow(
            color: colorScheme.foreground.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Stats Row
          Row(
            children: [
              _buildAnimatedStatItem(
                0,
                _formatNumber(widget.user.postsCount),
                'Posts',
                colorScheme,
                theme,
                onTap: () => widget.onStatsPressed('posts'),
              ),
              _buildDivider(colorScheme),
              _buildAnimatedStatItem(
                1,
                _formatNumber(widget.user.followersCount),
                'Followers',
                colorScheme,
                theme,
                onTap: () => widget.onStatsPressed('followers'),
              ),
              _buildDivider(colorScheme),
              _buildAnimatedStatItem(
                2,
                _formatNumber(widget.user.followingCount),
                'Following',
                colorScheme,
                theme,
                onTap: () => widget.onStatsPressed('following'),
              ),
            ],
          ),

          // Additional Stats (if available)
          if (widget.stats != null) ...[
            const SizedBox(height: 20),
            _buildAdditionalStats(colorScheme, theme),
          ],

          // Recent Activity Indicators
          const SizedBox(height: 16),
          _buildActivityIndicators(colorScheme, theme),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatItem(
    int index,
    String count,
    String label,
    ShadColorScheme colorScheme,
    ShadThemeData theme, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _animations[index].value,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      count,
                      style: theme.textTheme.h4?.copyWith(
                        color: colorScheme.foreground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: theme.textTheme.small?.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDivider(ShadColorScheme colorScheme) {
    return Container(
      height: 40,
      width: 1,
      color: colorScheme.border,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildAdditionalStats(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    final stats = widget.stats!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.muted.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Engagement Stats
          Row(
            children: [
              _buildSmallStat(
                'Total Likes',
                _formatNumber(stats.totalLikes),
                LucideIcons.heart,
                colorScheme,
                theme,
              ),
              const Spacer(),
              _buildSmallStat(
                'Total Views',
                _formatNumber(stats.totalViews),
                LucideIcons.eye,
                colorScheme,
                theme,
              ),
              const Spacer(),
              _buildSmallStat(
                'Comments',
                _formatNumber(stats.totalComments),
                LucideIcons.messageCircle,
                colorScheme,
                theme,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Growth Stats
          Row(
            children: [
              _buildGrowthIndicator(
                'This Week',
                stats.weeklyGrowth,
                colorScheme,
                theme,
              ),
              const Spacer(),
              _buildGrowthIndicator(
                'This Month',
                stats.monthlyGrowth,
                colorScheme,
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(
    String label,
    String value,
    IconData icon,
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.mutedForeground,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.small?.copyWith(
            color: colorScheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.small?.copyWith(
            color: colorScheme.mutedForeground,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthIndicator(
    String period,
    double growthPercentage,
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    final isPositive = growthPercentage >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${isPositive ? '+' : ''}${growthPercentage.toStringAsFixed(1)}%',
          style: theme.textTheme.small?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          period,
          style: theme.textTheme.small?.copyWith(
            color: colorScheme.mutedForeground,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityIndicators(
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return AnimatedBuilder(
      animation: _animations[3],
      builder: (context, child) {
        return Opacity(
          opacity: _animations[3].value,
          child: Row(
            children: [
              _buildActivityChip(
                'Active User',
                widget.user.isActive,
                colorScheme,
                theme,
              ),
              const SizedBox(width: 8),
              if (widget.user.isVerified)
                _buildActivityChip(
                  'Verified',
                  true,
                  colorScheme,
                  theme,
                  color: colorScheme.primary,
                ),
              if (widget.user.isPremium) ...[
                const SizedBox(width: 8),
                _buildActivityChip(
                  'Premium',
                  true,
                  colorScheme,
                  theme,
                  color: const Color(0xFFFFD700),
                ),
              ],
              const Spacer(),
              Text(
                'Last active: ${_getLastActiveText()}',
                style: theme.textTheme.small?.copyWith(
                  color: colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityChip(
    String label,
    bool isActive,
    ShadColorScheme colorScheme,
    ShadThemeData theme, {
    Color? color,
  }) {
    final chipColor = color ?? (isActive ? Colors.green : colorScheme.muted);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: chipColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: chipColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.small?.copyWith(
              color: chipColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return Helpers.formatNumber(number);
  }

  String _getLastActiveText() {
    if (widget.user.isActive) {
      return 'Now';
    }
    // This would typically come from user's last activity timestamp
    return '2h ago';
  }
}
