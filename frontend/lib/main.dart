import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/features/splash/splash_screen.dart';
import 'package:persona_mirror/features/auth/login_screen.dart';
import 'package:persona_mirror/features/dashboard/dashboard_screen.dart';
import 'package:persona_mirror/features/scenario/create_scenario_screen.dart';
import 'package:persona_mirror/features/simulation/simulation_screen.dart';
import 'package:persona_mirror/features/analysis/analysis_screen.dart';
import 'package:persona_mirror/features/settings/settings_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Falls back gracefully
  }
  runApp(const PersonaMirrorApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/create-scenario',
      builder: (context, state) => const CreateScenarioScreen(),
    ),
    GoRoute(
      path: '/simulation',
      builder: (context, state) => const SimulationScreen(),
    ),
    GoRoute(
      path: '/analysis',
      builder: (context, state) => const AnalysisScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class PersonaMirrorApp extends StatelessWidget {
  const PersonaMirrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Persona Mirror',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
