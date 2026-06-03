import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:persona_mirror/core/theme.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;
  final String? mood;
  final int? stressLevel;

  const PremiumBackground({
    super.key,
    required this.child,
    this.mood,
    this.stressLevel,
  });

  @override
  Widget build(BuildContext context) {
    // Default colors
    Color blobColor1 = AppTheme.accentViolet.withValues(alpha: 0.15);
    Color blobColor2 = AppTheme.accentCoral.withValues(alpha: 0.12);
    Color blobColor3 = AppTheme.accentSky.withValues(alpha: 0.1);

    if (mood != null) {
      switch (mood) {
        case 'satisfied':
          // Tranquil and cooperative green/teal hues
          blobColor1 = AppTheme.accentGreen.withValues(alpha: 0.16);
          blobColor2 = AppTheme.accentTeal.withValues(alpha: 0.14);
          blobColor3 = AppTheme.accentSky.withValues(alpha: 0.08);
          break;
        case 'defensive':
        case 'frustrated':
          // Cool, defensive blue, purple and violet hues
          blobColor1 = AppTheme.accentSky.withValues(alpha: 0.14);
          blobColor2 = AppTheme.accentViolet.withValues(alpha: 0.12);
          blobColor3 = AppTheme.accentPurple.withValues(alpha: 0.1);
          break;
        case 'agitated':
          // Tense, energetic orange and purple hues
          blobColor1 = AppTheme.accentCoral.withValues(alpha: 0.18);
          blobColor2 = AppTheme.accentGold.withValues(alpha: 0.14);
          blobColor3 = AppTheme.accentPurple.withValues(alpha: 0.1);
          break;
      }
    }

    // Stress levels above 6 force a higher intensity warm color glow
    if (stressLevel != null && stressLevel! > 6) {
      blobColor1 = AppTheme.accentCoral.withValues(alpha: 0.22);
      blobColor2 = AppTheme.accentGold.withValues(alpha: 0.15);
    }

    return Stack(
      children: [
        // Base Background
        Container(color: AppTheme.bgPrimary),
        
        // Animated Blobs using AnimatedContainer for smooth morphing transitions
        Positioned(
          top: -100,
          right: -50,
          child: _AnimatedBlob(
            color: blobColor1,
            size: 300,
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: _AnimatedBlob(
            color: blobColor2,
            size: 400,
          ),
        ),
        Positioned(
          top: 300,
          left: 50,
          child: _AnimatedBlob(
            color: blobColor3,
            size: 250,
          ),
        ),

        // Blur Filter
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),

        // Content
        child,
      ],
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _AnimatedBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
