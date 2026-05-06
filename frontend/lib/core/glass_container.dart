import 'package:flutter/material.dart';

import 'package:persona_mirror/core/theme.dart';

/// Design system card container.
/// Arka plan: [AppTheme.bgCard] (beyaz)
/// Gölge: [AppTheme.shadowCard] (hafif, diffuse)
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.shadows,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.bgCard,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        boxShadow: shadows ?? AppTheme.shadowCard,
        border: border,
      ),
      child: child,
    );
  }
}

/// Küçük yüzey aksan kartı — section arka planı için.
class AppSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppSectionCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

// ── Legacy alias — diğer ekranlar GlassContainer'ı kullanmaya devam edebilir.
// ignore: must_be_immutable
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 0,
    this.opacity = 1.0,
    this.borderRadius,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: AppTheme.shadowCard,
        border: border,
      ),
      child: child,
    );
  }
}
