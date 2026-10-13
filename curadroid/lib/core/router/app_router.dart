import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/dashboard/today_screen.dart';
import '../../features/checkin/checkin_screen.dart';
import '../../features/coach/coach_screen.dart';
import '../../features/exercises/exercise_runner.dart';
import '../../features/insights/insights_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/crisis/crisis_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../data/repositories/settings_repo.dart';

// Route paths
class AppRoutes {
  static const onboarding = '/onboarding';
  static const today = '/today';
  static const checkin = '/checkin';
  static const coach = '/coach';
  static const exercise = '/exercise';
  static const insights = '/insights';
  static const library = '/library';
  static const crisis = '/crisis';
  static const settings = '/settings';
}

/// Build the app router, injecting the settings repository so the redirect
/// guard can check the onboarding flag without async.
GoRouter buildAppRouter(SettingsRepository settings) {
  return GoRouter(
    initialLocation: AppRoutes.today,
    redirect: (context, state) {
      final onboarded = settings.onboarded;
      final goingToOnboarding = state.fullPath == AppRoutes.onboarding;

      // First launch → send to onboarding
      if (!onboarded && !goingToOnboarding) return AppRoutes.onboarding;
      // Already onboarded, trying to visit onboarding → redirect to today
      if (onboarded && goingToOnboarding) return AppRoutes.today;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),

      // ── Shell: 4-tab NavigationBar ─────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.today,
              builder: (_, __) => const TodayScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.insights,
              builder: (_, __) => const InsightsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.library,
              builder: (_, __) => const LibraryScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (_, __) => const SettingsScreen(),
            ),
          ]),
        ],
      ),

      // ── Modal routes (no nav bar) ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.checkin,
        builder: (_, __) => const CheckinScreen(),
      ),
      GoRoute(
        path: AppRoutes.coach,
        builder: (context, state) {
          final checkinId = state.extra as int?;
          return CoachScreen(checkinId: checkinId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.exercise}/:techniqueId',
        builder: (context, state) {
          final id = state.pathParameters['techniqueId']!;
          return ExerciseRunner(techniqueId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.crisis,
        builder: (_, __) => const CrisisScreen(),
      ),
    ],
  );
}

class _ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _ShellScaffold({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined),
            selectedIcon: Icon(Icons.self_improvement),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
