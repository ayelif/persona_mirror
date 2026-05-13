import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/features/auth/login_screen.dart';
import 'package:persona_mirror/features/auth/signup_screen.dart';
import 'package:persona_mirror/features/dashboard/dashboard_screen.dart';
import 'package:persona_mirror/features/settings/settings_screen.dart';
import 'package:persona_mirror/features/simulation/simulation_screen.dart';
import 'package:persona_mirror/features/analysis/analysis_screen.dart';
import 'package:persona_mirror/features/scenario/create_scenario_screen.dart';
import 'package:persona_mirror/core/models/scenario.dart';

// Router provider
final appRouter = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login', // Start with login for now
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/create-scenario',
        builder: (context, state) {
          final template = state.extra as Scenario?;
          return CreateScenarioScreen(template: template);
        },
      ),
      GoRoute(
        path: '/simulation',
        builder: (context, state) {
          final scenario = state.extra as Scenario;
          return SimulationScreen(scenario: scenario);
        },
      ),
      GoRoute(
        path: '/analysis',
        builder: (context, state) {
          final sessionId = state.extra as String;
          return AnalysisScreen(sessionId: sessionId);
        },
      ),
    ],
  );
});
