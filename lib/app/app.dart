// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/utils/logger.dart';

class App extends StatelessWidget {
  const App({super.key});

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
      child: MaterialApp.router(
        title: 'Social Network',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          // Global error boundary and global configurations
          return MediaQuery(
            // Ensure text scaling doesn't break the UI
            data: MediaQuery.of(context).copyWith(
              textScaleFactor:
                  MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
