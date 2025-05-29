import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import 'route_names.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static late final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: _redirect,
    routes: [
      // Splash route
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Auth routes
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        name: 'reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordPage(token: token);
        },
      ),
      GoRoute(
        path: RouteNames.verifyEmail,
        name: 'verify-email',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return VerifyEmailPage(token: token);
        },
      ),

      // Main app routes with shell navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // TODO: Return main app shell with bottom navigation
          return Scaffold(
            body: child,
            bottomNavigationBar:  BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: 'Notifications',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            builder: (context, state) => const Center(
              child: Text('Home Page - Coming Soon'),
            ),
          ),
          GoRoute(
            path: RouteNames.search,
            name: 'search',
            builder: (context, state) => const Center(
              child: Text('Search Page - Coming Soon'),
            ),
          ),
          GoRoute(
            path: RouteNames.notifications,
            name: 'notifications',
            builder: (context, state) => const Center(
              child: Text('Notifications Page - Coming Soon'),
            ),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: 'profile',
            builder: (context, state) => const Center(
              child: Text('Profile Page - Coming Soon'),
            ),
          ),
        ],
      ),
    ],
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    final currentLocation = state.uri.toString();

    // Define auth routes
    const authRoutes = [
      RouteNames.login,
      RouteNames.register,
      RouteNames.forgotPassword,
      RouteNames.resetPassword,
      RouteNames.verifyEmail,
    ];

    // Don't redirect if we're on splash page during initial load
    if (currentLocation == RouteNames.splash) {
      return null;
    }

    // If user is authenticated
    if (authState.isAuthenticated) {
      // Redirect to home if trying to access auth pages
      if (authRoutes.contains(currentLocation)) {
        return RouteNames.home;
      }
      return null; // Allow access to other pages
    }

    // If user is not authenticated
    if (!authState.isAuthenticated && authState.status != AuthStatus.initial) {
      // Allow access to auth pages
      if (authRoutes.contains(currentLocation)) {
        return null;
      }
      // Redirect to login for protected pages
      return RouteNames.login;
    }

    return null;
  }
}
