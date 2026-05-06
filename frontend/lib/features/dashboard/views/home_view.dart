import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/spacing.dart';
import 'package:persona_mirror/core/glass_container.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        _buildHeader(context),
        const SizedBox(height: AppSpacing.x3l),

        _buildSectionTitle(context, 'Hızlı Başlat'),
        const SizedBox(height: AppSpacing.md),
        _buildQuickStartRow(context),
        const SizedBox(height: AppSpacing.x3l),

        _buildSectionTitle(context, 'Geçmiş Oturumlar'),
        const SizedBox(height: AppSpacing.md),
        const _SessionListItem(title: 'Performans Geri Bildirimi', category: 'İş Dünyası', duration: '15 dk', score: '92', delay: 100),
        const _SessionListItem(title: 'Zorlu Müşteri Yönetimi', category: 'Satış', duration: '12 dk', score: '88', delay: 200),
        const SizedBox(height: AppSpacing.x3l),

        _buildSectionTitle(context, 'Duygu-Durum Analizi'),
        const SizedBox(height: AppSpacing.md),
        _buildProfessionalMoodTracker(),
        const SizedBox(height: AppSpacing.x5l),
      ],
    ).animate().fadeIn();
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppTheme.accentViolet, shape: BoxShape.circle)).animate().scale(delay: 200.ms),
                  const SizedBox(width: 8),
                  Text('HOŞ GELDİN, SARAH', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2.0, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Bugün hangi persona ile\naynalanmak istersin?', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26, height: 1.2, color: AppTheme.textPrimary)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/settings'),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.bgCard, shape: BoxShape.circle, boxShadow: AppTheme.shadowSm),
            child: const Icon(Icons.person_outline_rounded, color: AppTheme.accentViolet, size: 24),
          ),
        ).animate().fadeIn(delay: 400.ms).scale(),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textPrimary, fontSize: 17)),
        TextButton(onPressed: () {}, child: const Text('Tümünü Gör', style: TextStyle(color: AppTheme.accentViolet, fontSize: 13, fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _buildQuickStartRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _QuickStartCard(title: 'İş Görüşmesi', subtitle: 'Profesyonel Etki', icon: Icons.work_outline_rounded, color: AppTheme.accentViolet, onTap: () => context.push('/create-scenario')),
          const SizedBox(width: AppSpacing.md),
          _QuickStartCard(title: 'Topluluk Önünde', subtitle: 'Hitabet Gücü', icon: Icons.mic_none_rounded, color: AppTheme.accentCoral, onTap: () => context.push('/create-scenario')),
          const SizedBox(width: AppSpacing.md),
          _QuickStartCard(title: 'İkili İlişkiler', subtitle: 'Empati ve Bağ', icon: Icons.favorite_border_rounded, color: AppTheme.accentTeal, onTap: () => context.push('/create-scenario')),
        ],
      ),
    );
  }

  Widget _buildProfessionalMoodTracker() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: 24,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Duygusal Denge', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  Text('Son 7 günlük gelişim', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.accentGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Text('+%12 Pozitif', style: TextStyle(color: AppTheme.accentGreen, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MoodMetric(label: 'Özgüven', value: 0.85, color: AppTheme.accentViolet),
              _MoodMetric(label: 'Netlik', value: 0.72, color: AppTheme.accentTeal),
              _MoodMetric(label: 'Empati', value: 0.94, color: AppTheme.accentCoral),
            ],
          ),
        ],
      ),
    );
  }
}

// Reusable components (Internal to this view or could be moved to separate files)
class _QuickStartCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickStartCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});
  @override Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: 28,
        backgroundColor: Colors.white,
        margin: EdgeInsets.zero,
        child: SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color, size: 28)),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionListItem extends StatelessWidget {
  final String title, category, duration, score;
  final int delay;
  const _SessionListItem({required this.title, required this.category, required this.duration, required this.score, required this.delay});
  @override Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(14),
      borderRadius: 20,
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.bgSecondary, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.play_circle_outline, color: AppTheme.accentViolet)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)), const SizedBox(height: 2), Text('$category • $duration', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.accentGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(score, style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 14))),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms);
  }
}

class _MoodMetric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MoodMetric({required this.label, required this.value, required this.color});
  @override Widget build(BuildContext context) {
    return Column(children: [Stack(alignment: Alignment.center, children: [SizedBox(width: 50, height: 50, child: CircularProgressIndicator(value: value, strokeWidth: 6, backgroundColor: color.withValues(alpha: 0.1), valueColor: AlwaysStoppedAnimation<Color>(color), strokeCap: StrokeCap.round)), Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary))]), const SizedBox(height: 8), Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary))]);
  }
}
