import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/main_shell.dart';
import '../../core/navigation/root_gate.dart';
import '../../screens/auth_screen.dart';
import '../../screens/calendar_screen.dart';
import '../../screens/mode_selection_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/premium/premium_home_dashboard.dart';
import '../../screens/premium_reminders_screen.dart';
import '../../screens/premium_attendance_screen.dart';
import '../../screens/premium_profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const ZyvoraRootGate(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/mode',
        builder: (context, state) => const ModeSelectionScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/dashboard',
                builder: (context, state) => const PremiumHomeDashboard(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/tasks',
                builder: (context, state) => const PremiumRemindersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/attendance',
                builder: (context, state) => const PremiumAttendanceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/profile',
                builder: (context, state) => const PremiumProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
