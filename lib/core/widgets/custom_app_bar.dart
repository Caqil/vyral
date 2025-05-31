// lib/core/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool useShadcnStyle;
  final EdgeInsetsGeometry? padding;
  final double? toolbarHeight;
  final bool showBorder;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.bottom,
    this.systemOverlayStyle,
    this.useShadcnStyle = true,
    this.padding,
    this.toolbarHeight,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useShadcnStyle) {
      return _buildShadcnAppBar(context);
    } else {
      return _buildMaterialAppBar(context);
    }
  }

  Widget _buildShadcnAppBar(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    // Get effective colors
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.background;
    final effectiveForegroundColor = foregroundColor ?? colorScheme.foreground;

    // System overlay style based on background color
    final effectiveSystemOverlayStyle = systemOverlayStyle ??
        (effectiveBackgroundColor.computeLuminance() > 0.5
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: effectiveSystemOverlayStyle,
      child: Container(
        height: preferredSize.height,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          border: showBorder
              ? Border(
                  bottom: BorderSide(
                    color: colorScheme.border,
                    width: 1,
                  ),
                )
              : null,
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                    color: colorScheme.foreground.withOpacity(0.1),
                    blurRadius: elevation,
                    offset: Offset(0, elevation / 2),
                  ),
                ]
              : null,
        ),
        child: SafeArea(
          bottom: false,
          child: Container(
            height: toolbarHeight ?? kToolbarHeight,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Leading widget
                if (leading != null)
                  leading!
                else if (automaticallyImplyLeading &&
                    _shouldShowBackButton(context))
                  ShadButton.ghost(
                    onPressed: () => Navigator.maybePop(context),
                    child: Icon(
                      LucideIcons.arrowLeft,
                      size: 20,
                      color: effectiveForegroundColor,
                    ),
                  ),

                // Title section
                Expanded(
                  child: Container(
                    alignment: centerTitle
                        ? Alignment.center
                        : AlignmentDirectional.centerStart,
                    margin: EdgeInsets.only(
                      left: centerTitle &&
                              (leading != null ||
                                  (automaticallyImplyLeading &&
                                      _shouldShowBackButton(context)))
                          ? 0
                          : 16,
                      right:
                          centerTitle && (actions?.isNotEmpty == true) ? 0 : 16,
                    ),
                    child: titleWidget ??
                        (title != null
                            ? Text(
                                title!,
                                style: theme.textTheme.h4?.copyWith(
                                  color: effectiveForegroundColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null),
                  ),
                ),

                // Actions
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!.map((action) {
                      // Wrap non-shadcn buttons in proper styling
                      if (action is IconButton) {
                        return ShadButton.ghost(
                          onPressed: action.onPressed,
                          child: action.icon,
                        );
                      }
                      return action;
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialAppBar(BuildContext context) {
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      bottom: bottom,
      systemOverlayStyle: systemOverlayStyle,
      toolbarHeight: toolbarHeight,
    );
  }

  bool _shouldShowBackButton(BuildContext context) {
    final parentRoute = ModalRoute.of(context);
    return parentRoute?.canPop == true || (parentRoute?.isFirst == false);
  }

  @override
  Size get preferredSize => Size.fromHeight(
        (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
      );
}

// Extension to make accessing color scheme easier
extension on BuildContext {
  ShadColorScheme get colorScheme {
    final shadTheme = ShadTheme.of(this);
    return shadTheme.colorScheme;
  }
}

// Convenience constructors for common app bar types
extension CustomAppBarExtensions on CustomAppBar {
  static PreferredSizeWidget simple({
    Key? key,
    required String title,
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    bool centerTitle = true,
    bool showBorder = false,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      showBorder: showBorder,
    );
  }

  static PreferredSizeWidget search({
    Key? key,
    required Widget searchWidget,
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    bool showBorder = false,
  }) {
    return CustomAppBar(
      key: key,
      titleWidget: searchWidget,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: false,
      showBorder: showBorder,
    );
  }

  static PreferredSizeWidget custom({
    Key? key,
    required Widget customWidget,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    bool centerTitle = true,
    bool showBorder = false,
    EdgeInsetsGeometry? padding,
  }) {
    return CustomAppBar(
      key: key,
      titleWidget: customWidget,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      showBorder: showBorder,
      padding: padding,
    );
  }

  static PreferredSizeWidget withTab({
    Key? key,
    required String title,
    required TabBar tabBar,
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    bool centerTitle = true,
    bool showBorder = false,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      showBorder: showBorder,
      bottom: tabBar,
    );
  }

  static PreferredSizeWidget profile({
    Key? key,
    required String title,
    Widget? profileAction,
    List<Widget>? additionalActions,
    bool automaticallyImplyLeading = true,
  }) {
    List<Widget> actions = [];
    if (profileAction != null) {
      actions.add(profileAction);
    }
    if (additionalActions != null) {
      actions.addAll(additionalActions);
    }

    return CustomAppBar(
      key: key,
      title: title,
      actions: actions.isNotEmpty ? actions : null,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: true,
    );
  }

  static PreferredSizeWidget chat({
    Key? key,
    required Widget userInfo,
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
  }) {
    return CustomAppBar(
      key: key,
      titleWidget: userInfo,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: false,
      padding: const EdgeInsets.only(left: 8, right: 16),
    );
  }
}

// Shadcn-styled app bar actions
class ShadAppBarAction {
  static Widget icon({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color? iconColor,
    ShadButtonVariant variant = ShadButtonVariant.ghost,
  }) {
    Widget button = ShadButton.raw(
      variant: variant,
      onPressed: onPressed,
      child: Icon(icon, size: 20, color: iconColor),
    );

    if (tooltip != null) {
      button = ShadTooltip(
        builder: (context) => Text(tooltip),
        child: button,
      );
    }

    return button;
  }

  static Widget avatar({
    required String imageUrl,
    required VoidCallback onPressed,
    String? fallbackText,
    double size = 32,
  }) {
    return ShadButton.ghost(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        child: ShadAvatar(
          imageUrl.isNotEmpty
              ? imageUrl
              : 'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4',
          placeholder: Text('CN'),
        ));
  }

  static Widget badge({
    required IconData icon,
    required VoidCallback onPressed,
    required int count,
    String? tooltip,
    Color? iconColor,
    Color? badgeColor,
  }) {
    Widget button = ShadButton.ghost(
      onPressed: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: 20, color: iconColor),
          if (count > 0)
            Positioned(
              right: -6,
              top: -6,
              child: ShadBadge(
                backgroundColor: badgeColor,
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );

    if (tooltip != null) {
      button = ShadTooltip(
        builder: (context) => Text(tooltip),
        child: button,
      );
    }

    return button;
  }

  static Widget menu({
    required List<Widget> menuItems,
    IconData icon = LucideIcons.moveRight,
    String? tooltip,
    Color? iconColor,
  }) {
    Widget button = ShadContextMenu(
      items: menuItems,
      child: ShadButton.ghost(
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );

    if (tooltip != null) {
      button = ShadTooltip(
        builder: (context) => Text(tooltip),
        child: button,
      );
    }

    return button;
  }
}
