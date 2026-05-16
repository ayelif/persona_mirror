import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:persona_mirror/core/theme.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Background
        Container(color: AppTheme.bgPrimary),
        
        // Animated/Static Blobs
        Positioned(
          top: -100,
          right: -50,
          child: _Blob(
            color: AppTheme.accentViolet.withValues(alpha: 0.15),
            size: 300,
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: _Blob(
            color: AppTheme.accentCoral.withValues(alpha: 0.12),
            size: 400,
          ),
        ),
        Positioned(
          top: 300,
          left: 50,
          child: _Blob(
            color: AppTheme.accentSky.withValues(alpha: 0.1),
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

class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
