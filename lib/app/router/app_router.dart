// Updated App Router - lib/app/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../main.dart'; // For dependency injection
import 'route_names.dart';
import 'profile_routes.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static late final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash, // Always start with splash
    debugLogDiagnostics: true,
    redirect: _redirect,
    errorBuilder: (context, state) => _buildErrorPage(context, state),
    routes: [
      // Splash route (always accessible)
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

      // Profile routes (outside shell for full-screen experience)
      ...profileRoutes,

      // Main app routes with shell navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // Home route (root)
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            builder: (context, state) {
              return Scaffold(
                  body: Center(
                      child: ShadButton.ghost(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.logOut, size: 16),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              )));
            },
          ),

          // Search route
          GoRoute(
            path: RouteNames.search,
            name: 'search',
            builder: (context, state) {
              final query = state.uri.queryParameters['query'];
              return Scaffold(
                body: Center(
                  child: Text(query != null
                      ? 'Searching for: $query'
                      : 'Search Page - Coming Soon'),
                ),
              );
            },
          ),

          // Notifications route
          GoRoute(
            path: RouteNames.notifications,
            name: 'notifications',
            builder: (context, state) {
              return const Scaffold(
                body: Center(
                  child: Text('Notifications Page - Coming Soon'),
                ),
              );
            },
          ),

          // Messages route
          GoRoute(
            path: RouteNames.messages,
            name: 'messages',
            builder: (context, state) {
              return const Scaffold(
                body: Center(
                  child: Text('Messages Page - Coming Soon'),
                ),
              );
            },
            routes: [
              // New conversation route
              GoRoute(
                path: '/new',
                name: 'new-conversation',
                builder: (context, state) {
                  final userId = state.uri.queryParameters['userId'];
                  return Scaffold(
                    body: Center(
                      child: Text(userId != null
                          ? 'New conversation with user: $userId'
                          : 'New Conversation Page'),
                    ),
                  );
                },
              ),

              // Conversation detail route
              GoRoute(
                path: '/:conversationId',
                name: 'conversation',
                builder: (context, state) {
                  final conversationId =
                      state.pathParameters['conversationId']!;
                  return Scaffold(
                    body: Center(
                      child: Text('Conversation: $conversationId'),
                    ),
                  );
                },
              ),
            ],
          ),

          // Current user profile route (inside shell)
          GoRoute(
            path: RouteNames.profile,
            name: 'current-user-profile',
            builder: (context, state) {
              // Get current user ID from AuthBloc
              final authBloc = context.read<AuthBloc>();
              final currentUserId = authBloc.state.user?.id;

              if (currentUserId == null) {
                // If no current user, redirect to login
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go(RouteNames.login);
                });
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return BlocProvider(
                create: (context) => _createProfileBloc(),
                child: ProfilePage(
                  userId: currentUserId,
                  username: authBloc.state.user?.username,
                ),
              );
            },
          ),
        ],
      ),
    ],
  );

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
            ],
          ),
        ),
      ),
    );
  }

  static String? _redirect(BuildContext context, GoRouterState state) {
    final currentLocation = state.uri.toString();

    print('Router redirect: Current location = $currentLocation'); // Debug log

    // Always allow splash page
    if (currentLocation == RouteNames.splash) {
      return null;
    }

    // Get auth state - but don't redirect if we're still loading
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    print('Router redirect: Auth status = ${authState.status}'); // Debug log

    // Define auth routes
    const authRoutes = [
      RouteNames.login,
      RouteNames.register,
      RouteNames.forgotPassword,
      RouteNames.resetPassword,
      RouteNames.verifyEmail,
    ];

    // If auth state is still initial or loading, redirect to splash
    if (authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.loading) {
      return RouteNames.splash;
    }

    // If user is authenticated
    if (authState.status == AuthStatus.authenticated) {
      // Redirect to home if trying to access auth pages
      if (authRoutes.contains(currentLocation)) {
        return RouteNames.home;
      }
      return null; // Allow access to other pages
    }

    // If user is not authenticated
    if (authState.status == AuthStatus.unauthenticated) {
      // Allow access to auth pages and public profile pages
      if (authRoutes.contains(currentLocation) ||
          currentLocation.startsWith('/profile/') ||
          currentLocation.startsWith('/u/') ||
          currentLocation.startsWith('/post/')) {
        return null;
      }
      // Redirect to login for protected pages
      return RouteNames.login;
    }

    return null;
  }

  // Dependency injection helper
  static ProfileBloc _createProfileBloc() {
    return ProfileBloc(
      getUserProfile: SocialNetworkApp.getUserProfileUseCase(),
      getUserPosts: SocialNetworkApp.getUserPostsUseCase(),
      getUserMedia: SocialNetworkApp.getUserMediaUseCase(),
      followUser: SocialNetworkApp.getFollowUserUseCase(),
      unfollowUser: SocialNetworkApp.getUnfollowUserUseCase(),
      getFollowStatus: SocialNetworkApp.getFollowStatusUseCase(),
      getUserStats: SocialNetworkApp.getUserStatsUseCase(),
      getCurrentUserId: () => SocialNetworkApp.getCurrentUserId(),
    );
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
      item: const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      route: RouteNames.home,
    ),
    NavigationItem(
      item: const BottomNavigationBarItem(
        icon: Icon(Icons.search_outlined),
        activeIcon: Icon(Icons.search),
        label: 'Search',
      ),
      route: RouteNames.search,
    ),
    NavigationItem(
      item: const BottomNavigationBarItem(
        icon: Icon(Icons.notifications_outlined),
        activeIcon: Icon(Icons.notifications),
        label: 'Notifications',
      ),
      route: RouteNames.notifications,
    ),
    NavigationItem(
      item: const BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        activeIcon: Icon(Icons.chat_bubble),
        label: 'Messages',
      ),
      route: RouteNames.messages,
    ),
    NavigationItem(
      item: const BottomNavigationBarItem(
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

    _currentIndex = _navigationItems.indexWhere(
      (item) => currentLocation.startsWith(item.route),
    );
    if (_currentIndex == -1) _currentIndex = 0;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: _navigationItems.map((navItem) => navItem.item).toList(),
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index != _currentIndex) {
            final route = _navigationItems[index].route;
            context.go(route);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateOptions(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.post_add),
              title: const Text('Create Post'),
              onTap: () {
                Navigator.pop(context);
                context.go('/post/create');
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Create Story'),
              onTap: () {
                Navigator.pop(context);
                context.go('/story/create');
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_call),
              title: const Text('Go Live'),
              onTap: () {
                Navigator.pop(context);
                // Handle live streaming
              },
            ),
          ],
        ),
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
