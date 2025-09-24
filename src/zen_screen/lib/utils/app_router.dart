import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/welcome_screen.dart';
import '../screens/home_screen.dart';
import '../screens/log_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/how_it_works_screen.dart';

/// Route names for type-safe navigation
class AppRoutes {
  static const String welcome = '/';
  static const String home = '/home';
  static const String log = '/log';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String howItWorks = '/how-it-works';
}

/// Creates a new GoRouter instance for Navigator 2.0 support.
///
/// A factory method ensures tests can instantiate isolated router instances
/// without reusing global navigation state between runs.
GoRouter appRouterFactory({String initialLocation = AppRoutes.welcome}) {
  return GoRouter(
    initialLocation: initialLocation,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.log,
        name: 'log',
        builder: (context, state) => const LogScreen(),
      ),
      GoRoute(
        path: AppRoutes.progress,
        name: 'progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.howItWorks,
        name: 'how-it-works',
        builder: (context, state) => const HowItWorksScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri.toString()}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.welcome),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Default application router instance.
final GoRouter appRouter = appRouterFactory();
