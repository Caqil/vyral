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
import '../../shared/widgets/bottom_navigation.dart';
import 'route_names.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static late final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.home, // Start at '/'
    debugLogDiagnostics: true, // This will help debug routing issues
    redirect: _redirect,
    errorBuilder: (context, state) => _buildErrorPage(context, state),
    routes: [
      // Splash route (outside shell)
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Auth routes (outside shell)
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
          return MainShell(child: child);
        },
        routes: [
          // Home route (root)
          GoRoute(
            path: RouteNames.home, // '/'
            name: 'home',
            builder: (context, state) {
              return const Scaffold(
                body: Center(
                  child: Text('Search Page - Coming Soon'),
                ),
              );
            },
          ),

          // Search route
          GoRoute(
            path: RouteNames.search, // '/search'
            name: 'search',
            builder: (context, state) {
              print('Building search route: ${state.uri}'); // Debug
              return const Scaffold(
                body: Center(
                  child: Text('Search Page - Coming Soon'),
                ),
              );
            },
          ),

          // Notifications route
          GoRoute(
            path: RouteNames.notifications, // '/notifications'
            name: 'notifications',
            builder: (context, state) {
              print('Building notifications route: ${state.uri}'); // Debug
              return const Scaffold(
                body: Center(
                  child: Text('Notifications Page - Coming Soon'),
                ),
              );
            },
          ),

          // Profile route
          GoRoute(
            path: RouteNames.profile, // '/profile'
            name: 'profile',
            builder: (context, state) {
              print('Building profile route: ${state.uri}'); // Debug
              return const Scaffold(
                body: Center(
                  child: Text('Profile Page - Coming Soon'),
                ),
              );
            },
          ),

          // Messages route
          GoRoute(
            path: RouteNames.messages, // '/messages'
            name: 'messages',
            builder: (context, state) {
              print('Building messages route: ${state.uri}'); // Debug
              return const Scaffold(
                body: Center(
                  child: Text('Messages Page - Coming Soon'),
                ),
              );
            },
          ),
        ],
      ),
    ],
  );

  // Custom error page for debugging
  static Widget _buildErrorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                '404 - Route Not Found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Path: ${state.uri}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.home),
                child: const Text('Go to Home'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // Print all available routes for debugging
                  print('Available routes:');
                  print('- ${RouteNames.home}');
                  print('- ${RouteNames.feed}');
                  print('- ${RouteNames.search}');
                  print('- ${RouteNames.notifications}');
                  print('- ${RouteNames.profile}');
                  print('- ${RouteNames.messages}');
                },
                child: const Text('Debug Routes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _redirect(BuildContext context, GoRouterState state) {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    final currentLocation = state.uri.toString();

    print('Router redirect - Current location: $currentLocation'); // Debug
    print('Auth status: ${authState.status}'); // Debug

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
      print(
          'User is authenticated, current location: $currentLocation'); // Debug
      // Redirect to home if trying to access auth pages
      if (authRoutes.contains(currentLocation)) {
        print('Redirecting from auth page to home'); // Debug
        return RouteNames.home;
      }
      return null; // Allow access to other pages
    }

    // If user is not authenticated
    if (!authState.isAuthenticated && authState.status != AuthStatus.initial) {
      print(
          'User not authenticated, current location: $currentLocation'); // Debug
      // Allow access to auth pages
      if (authRoutes.contains(currentLocation)) {
        return null;
      }
      // Redirect to login for protected pages
      print('Redirecting to login'); // Debug
      return RouteNames.login;
    }

    return null;
  }
}

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      item: BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      route: RouteNames.home,
    ),
    NavigationItem(
      item: BottomNavigationBarItem(
        icon: Icon(Icons.search_outlined),
        activeIcon: Icon(Icons.search),
        label: 'Search',
      ),
      route: RouteNames.search,
    ),
    NavigationItem(
      item: BottomNavigationBarItem(
        icon: Icon(Icons.notifications_outlined),
        activeIcon: Icon(Icons.notifications),
        label: 'Notifications',
      ),
      route: RouteNames.notifications,
    ),
    NavigationItem(
      item: BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        activeIcon: Icon(Icons.chat_bubble),
        label: 'Messages',
      ),
      route: RouteNames.messages,
    ),
    NavigationItem(
      item: BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
      route: RouteNames.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Get current route to determine active tab
    final currentLocation = GoRouterState.of(context).uri.toString();
    print('MainShell - Current location: $currentLocation'); // Debug

    _currentIndex = _navigationItems.indexWhere(
      (item) => item.route == currentLocation,
    );
    if (_currentIndex == -1) _currentIndex = 0;

    print('MainShell - Current index: $_currentIndex'); // Debug

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: _navigationItems.map((navItem) => navItem.item).toList(),
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index != _currentIndex) {
            final route = _navigationItems[index].route;
            print('Navigating to: $route'); // Debug
            context.go(route);
          }
        },
      ),
    );
  }
}

class NavigationItem {
  final BottomNavigationBarItem item;
  final String route;

  NavigationItem({
    required this.item,
    required this.route,
  });
}
