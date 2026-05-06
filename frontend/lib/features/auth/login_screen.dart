import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/spacing.dart';
import 'package:persona_mirror/core/radius.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulated loading — frontend-only demo mode
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() => _isLoading = false);
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _HeroHeader(),
              _LoginCard(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                isPasswordVisible: _isPasswordVisible,
                isLoading: _isLoading,
                onTogglePassword: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
                onLogin: _handleLogin,
              ),
              const SizedBox(height: AppSpacing.x3l),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero Header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppLayout.screenPaddingH,
        AppSpacing.x5l,
        AppLayout.screenPaddingH,
        AppSpacing.x4l,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.bgPrimary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Logo Icon ──────────────────────────────────
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.accentViolet, AppTheme.accentPurple],
              ),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              boxShadow: AppTheme.glowViolet,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: AppTheme.textInverse,
              size: 40,
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: AppSpacing.xl),

          // ── Title ─────────────────────────────────────
          Text(
            'Persona Mirror',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  letterSpacing: -0.3,
                ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 500.ms)
              .slideY(begin: 0.25, curve: Curves.easeOut),

          const SizedBox(height: 8),

          // ── Subtitle ──────────────────────────────────
          Text(
            'Dijital benliğini keşfet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 500.ms),

          const SizedBox(height: AppSpacing.xl),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}



// ── Login Card ───────────────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenPaddingH),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppTheme.shadowLg,
        ),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section Title ────────────────────────
              Text(
                'Giriş Yap',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.xs),

              Text(
                'Hesabına giriş yap, kişiliğini keşfet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 450.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.xxl),

              // ── Divider ──────────────────────────────
              const Divider(color: AppTheme.borderLight, height: 1),

              const SizedBox(height: AppSpacing.xxl),

              // ── Email Field ──────────────────────────
              _FieldLabel(label: 'E-posta')
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  hintText: 'ornek@email.com',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    size: 20,
                    color: AppTheme.textTertiary,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'E-posta adresi giriniz';
                  }
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'Geçerli bir e-posta adresi giriniz';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 540.ms, duration: 400.ms)
                  .slideX(begin: -0.04, curve: Curves.easeOut),

              const SizedBox(height: AppSpacing.lg),

              // ── Password Field ───────────────────────
              _FieldLabel(label: 'Şifre')
                  .animate()
                  .fadeIn(delay: 580.ms, duration: 400.ms),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onLogin(),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: AppTheme.textTertiary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textTertiary,
                      size: 20,
                    ),
                    onPressed: onTogglePassword,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Şifre giriniz';
                  if (v.length < 6) return 'Şifre en az 6 karakter olmalı';
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 620.ms, duration: 400.ms)
                  .slideX(begin: -0.04, curve: Curves.easeOut),

              const SizedBox(height: 10),

              // ── Forgot Password ──────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {/* TODO: forgot password */},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Şifremi unuttum',
                    style: TextStyle(
                      color: AppTheme.accentViolet,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 660.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.x3l),

              // ── Login Button ─────────────────────────
              _PrimaryButton(
                label: 'Giriş Yap',
                isLoading: isLoading,
                onPressed: onLogin,
              )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 400.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOut),

              const SizedBox(height: AppSpacing.xl),

              // ── Divider ──────────────────────────────
              Row(
                children: [
                  const Expanded(
                    child: Divider(color: AppTheme.borderLight),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      'veya',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: AppTheme.borderLight),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 750.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.lg),

              // ── Social Login ─────────────────────────
              _OutlineButton(
                label: 'Google ile devam et',
                icon: Icons.g_mobiledata_rounded,
                iconColor: AppTheme.accentCoral,
                onPressed: () {/* TODO: Google sign-in */},
              )
                  .animate()
                  .fadeIn(delay: 790.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.xxl),

              // ── Sign Up Prompt ───────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hesabın yok mu?  ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    GestureDetector(
                      onTap: () {/* TODO: sign up */},
                      child: const Text(
                        'Kayıt ol',
                        style: TextStyle(
                          color: AppTheme.accentViolet,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 830.ms, duration: 400.ms),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(delay: 380.ms, duration: 500.ms)
          .slideY(begin: 0.08, curve: Curves.easeOut),
    );
  }
}

// ── Field Label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }
}

// ── Primary Gradient Button ───────────────────────────────────────────────────

class _PrimaryButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppTheme.accentViolet, AppTheme.accentPurple],
            ),
            borderRadius: AppRadius.buttonRadius,
            boxShadow: AppTheme.glowViolet,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppTheme.textInverse,
                    ),
                  )
                : const Text(
                    'Giriş Yap',
                    style: TextStyle(
                      color: AppTheme.textInverse,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Outline Button ───────────────────────────────────────────────────────────

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: AppLayout.listItemHeight,
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: AppRadius.buttonRadius,
          border: Border.all(color: AppTheme.borderMedium),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
