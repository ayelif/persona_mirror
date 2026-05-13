import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme/app_theme.dart';
import 'package:persona_mirror/core/constants/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Oturum kontrolü
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        context.go('/dashboard');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Dekoratif daireler
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.05),
              ),
            ),
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.glassDecoration,
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
              
              const SizedBox(height: 32),
              
              Text(
                AppConstants.appName.toUpperCase(),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  letterSpacing: 4,
                  fontSize: 24,
                  color: AppTheme.primaryColor,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 12),
              
              Text(
                AppConstants.appTagline,
                style: const TextStyle(
                  color: AppTheme.mutedTextColor,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ],
      ),
    );
  }
}
