// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/utils/logger.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Theme management state
  String _currentTheme = AppTheme.defaultTheme;
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(String themeName) {
    setState(() {
      _currentTheme = themeName;
    });
  }

  void _changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Log authentication state changes
        AppLogger.info('Auth state changed: ${state.status}');

        // Handle authentication state changes if needed
        if (state.status == AuthStatus.unauthenticated &&
            state.errorMessage != null) {
          AppLogger.warning('Authentication failed: ${state.errorMessage}');
        }
      },
      child: ShadApp.router(
        title: 'Social Network',
        debugShowCheckedModeBanner: false,

        // Shadcn UI themes
        theme: AppTheme.getLightTheme(_currentTheme),
        darkTheme: AppTheme.getDarkTheme(_currentTheme),
        themeMode: _themeMode,
        routerConfig: AppRouter.router,

        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                  MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2)),
            ),
            child: ThemeProvider(
              themeName: _currentTheme,
              themeMode: _themeMode,
              onThemeChanged: _changeTheme,
              onThemeModeChanged: _changeThemeMode,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}

// Theme provider for managing theme state across the app
class ThemeProvider extends InheritedWidget {
  const ThemeProvider({
    super.key,
    required this.themeName,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onThemeModeChanged,
    required super.child,
  });

  final String themeName;
  final ThemeMode themeMode;
  final ValueChanged<String> onThemeChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return themeName != oldWidget.themeName || themeMode != oldWidget.themeMode;
  }
}

// Helper class for theme management
class AppThemeManager {
  static ThemeProvider? _of(BuildContext context) => ThemeProvider.of(context);

  /// Get current theme name
  static String getCurrentTheme(BuildContext context) {
    return _of(context)?.themeName ?? AppTheme.defaultTheme;
  }

  /// Get current theme mode
  static ThemeMode getCurrentThemeMode(BuildContext context) {
    return _of(context)?.themeMode ?? ThemeMode.system;
  }

  /// Change theme color scheme
  static void changeTheme(BuildContext context, String themeName) {
    _of(context)?.onThemeChanged(themeName);
  }

  /// Change theme mode (light/dark/system)
  static void changeThemeMode(BuildContext context, ThemeMode mode) {
    _of(context)?.onThemeModeChanged(mode);
  }

  /// Toggle between light and dark mode
  static void toggleThemeMode(BuildContext context) {
    final currentMode = getCurrentThemeMode(context);
    final newMode =
        currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    changeThemeMode(context, newMode);
  }

  /// Get available theme names
  static List<String> getAvailableThemes() {
    return AppTheme.availableThemes;
  }

  /// Get user-friendly theme name
  static String getThemeDisplayName(String themeName) {
    return themeName.split('').first.toUpperCase() + themeName.substring(1);
  }

  /// Check if current theme is dark
  static bool isDarkMode(BuildContext context) {
    final themeMode = getCurrentThemeMode(context);
    switch (themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }

  /// Get current Shadcn color scheme
  static ShadColorScheme getCurrentColorScheme(BuildContext context) {
    final themeName = getCurrentTheme(context);
    final isDark = isDarkMode(context);

    return isDark
        ? AppTheme.getDarkTheme(themeName).colorScheme
        : AppTheme.getLightTheme(themeName).colorScheme;
  }
}

// Extension to make theme management easier in widgets
extension AppThemeExtension on BuildContext {
  /// Get current theme name
  String get currentTheme => AppThemeManager.getCurrentTheme(this);

  /// Get current theme mode
  ThemeMode get currentThemeMode => AppThemeManager.getCurrentThemeMode(this);

  /// Change theme
  void changeTheme(String themeName) =>
      AppThemeManager.changeTheme(this, themeName);

  /// Change theme mode
  void changeThemeMode(ThemeMode mode) =>
      AppThemeManager.changeThemeMode(this, mode);

  /// Toggle theme mode
  void toggleThemeMode() => AppThemeManager.toggleThemeMode(this);

  /// Check if dark mode
  bool get isDarkMode => AppThemeManager.isDarkMode(this);

  /// Get current color scheme
  ShadColorScheme get colorScheme =>
      AppThemeManager.getCurrentColorScheme(this);

  /// Get available themes
  List<String> get availableThemes => AppThemeManager.getAvailableThemes();
}
