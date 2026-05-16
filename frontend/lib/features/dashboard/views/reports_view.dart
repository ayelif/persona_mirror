import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/glass_container.dart';
import 'package:persona_mirror/core/di/scenario_provider.dart';

class ReportsView extends ConsumerWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentViolet)),
      error: (err, stack) => Center(child: Text('İstatistikler yüklenemedi: $err')),
      data: (stats) {
        final totalSessions = stats['total_sessions'] ?? 0;
        final avgScore = stats['avg_score'] ?? 0;
        final skills = stats['skills'] as Map? ?? {};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gelişim Yolculuğun',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
            const SizedBox(height: 8),
            const Text(
              'AI tarafından analiz edilen tüm konuşmalarının özeti.',
              style: TextStyle(color: AppTheme.textSecondary),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 32),
            
            // Özet İstatistikler
            Row(
              children: [
                _buildStatCard('Toplam Prova', totalSessions.toString(), Icons.chat_bubble_outline_rounded, AppTheme.accentViolet),
                const SizedBox(width: 16),
                _buildStatCard('Ort. Skor', avgScore.toString(), Icons.star_outline_rounded, AppTheme.accentGold),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 40),
            const Text('Yetenek Grafiğin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary))
                .animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
            
            // Yetenek Kartları
            _buildSkillProgress('Empati', (skills['Empati'] ?? 0.0), AppTheme.accentCoral, 0),
            const SizedBox(height: 12),
            _buildSkillProgress('Netlik', (skills['Netlik'] ?? 0.0), AppTheme.accentSky, 1),
            const SizedBox(height: 12),
            _buildSkillProgress('Kararlılık', (skills['Kararlılık'] ?? 0.0), AppTheme.accentTeal, 2),
            
            const SizedBox(height: 40),
            AppCard(
              padding: const EdgeInsets.all(24),
              backgroundColor: AppTheme.accentViolet.withValues(alpha: 0.05),
              border: Border.all(color: AppTheme.accentViolet.withValues(alpha: 0.1)),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentViolet),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      totalSessions == 0 
                        ? 'Henüz hiç prova yapmadın. İlk provanı yaparak analizlerini burada görebilirsin!'
                        : 'Harika gidiyorsun! Toplam $totalSessions prova yaparak büyük bir adım attın.',
                      style: const TextStyle(color: AppTheme.accentViolet, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms).shimmer(delay: 2.seconds, duration: 1.5.seconds),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillProgress(String label, double progress, Color color, int index) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              Text('%${(progress * 100).toInt()}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.1),
              color: color,
              minHeight: 10,
            ),
          ).animate(delay: (400 + (index * 100)).ms).shimmer(duration: 1.seconds),
        ],
      ),
    ).animate().fadeIn(delay: (400 + (index * 100)).ms).slideX(begin: 0.05, end: 0);
  }
}


