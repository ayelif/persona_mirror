import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
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
        final achievements = stats['achievements'] as List? ?? [];

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
            
            // Radar Grafik Görselleştirmesi
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: SizedBox(
                height: 220,
                child: RadarChart(
                  RadarChartData(
                    dataSets: [
                      RadarDataSet(
                        fillColor: AppTheme.accentViolet.withValues(alpha: 0.15),
                        borderColor: AppTheme.accentViolet,
                        entryRadius: 4,
                        borderWidth: 2.5,
                        dataEntries: [
                          RadarEntry(value: (skills['Empati'] ?? 0.0).toDouble() * 10),
                          RadarEntry(value: (skills['Netlik'] ?? 0.0).toDouble() * 10),
                          RadarEntry(value: (skills['Kararlılık'] ?? 0.0).toDouble() * 10),
                        ],
                      ),
                    ],
                    radarBorderData: const BorderSide(color: Colors.transparent),
                    radarShape: RadarShape.polygon,
                    radarBackgroundColor: Colors.transparent,
                    getTitle: (index, angle) {
                      switch (index) {
                        case 0:
                          return const RadarChartTitle(text: 'Empati', angle: 0);
                        case 1:
                          return const RadarChartTitle(text: 'Netlik', angle: 0);
                        case 2:
                          return const RadarChartTitle(text: 'Kararlılık', angle: 0);
                        default:
                          return const RadarChartTitle(text: '');
                      }
                    },
                    titlePositionPercentageOffset: 0.18,
                    titleTextStyle: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                    gridBorderData: BorderSide(color: AppTheme.textTertiary.withValues(alpha: 0.12), width: 1),
                    tickBorderData: BorderSide(color: AppTheme.textTertiary.withValues(alpha: 0.12), width: 1),
                    ticksTextStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 9),
                    tickCount: 3,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 350.ms).scale(begin: const Offset(0.95, 0.95)),
            
            const SizedBox(height: 24),
            
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

            const SizedBox(height: 40),
            const Text(
              'Başarı Rozetlerin', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary)
            ).animate().fadeIn(delay: 750.ms),
            const SizedBox(height: 16),
            achievements.isEmpty 
              ? const SizedBox.shrink()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final ach = Map<String, dynamic>.from(achievements[index]);
                    return _buildBadgeCard(context, ach);
                  },
                ).animate().fadeIn(delay: 800.ms),
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }

  IconData _getBadgeIcon(String iconName) {
    switch (iconName) {
      case 'first_step':
        return Icons.rocket_launch_rounded;
      case 'empathy':
        return Icons.favorite_rounded;
      case 'assertive':
        return Icons.bolt_rounded;
      case 'genius':
        return Icons.auto_awesome_rounded;
      case 'consistent':
        return Icons.event_available_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  Color _getBadgeColor(String colorName) {
    switch (colorName) {
      case 'violet':
        return AppTheme.accentViolet;
      case 'coral':
        return AppTheme.accentCoral;
      case 'sky':
        return AppTheme.accentSky;
      case 'gold':
        return AppTheme.accentGold;
      case 'teal':
        return AppTheme.accentTeal;
      default:
        return AppTheme.accentViolet;
    }
  }

  Widget _buildBadgeCard(BuildContext context, Map<String, dynamic> ach) {
    final isUnlocked = ach['isUnlocked'] as bool? ?? false;
    final progress = (ach['progress'] as num? ?? 0.0).toDouble();
    final color = _getBadgeColor(ach['colorName'] ?? '');
    final icon = _getBadgeIcon(ach['iconName'] ?? '');

    final cardChild = AppCard(
      padding: const EdgeInsets.all(16),
      border: Border.all(
        color: isUnlocked ? color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.2),
        width: 1.5,
      ),
      backgroundColor: isUnlocked ? Colors.white.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.35),
      child: Stack(
        children: [
          // Background soft radial glow for unlocked badges
          if (isUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [color.withValues(alpha: 0.12), Colors.transparent],
                    radius: 0.7,
                  ),
                ),
              ),
            ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Beautiful Glowing Multi-Layered Icon Wrapper
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked ? color.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: isUnlocked 
                      ? LinearGradient(
                          colors: [color, color.withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey.withValues(alpha: 0.1), Colors.grey.withValues(alpha: 0.05)],
                        ),
                    shape: BoxShape.circle,
                    boxShadow: isUnlocked ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ] : null,
                  ),
                  child: Icon(
                    icon,
                    color: isUnlocked ? Colors.white : Colors.grey.withValues(alpha: 0.4),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                ach['title'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isUnlocked ? AppTheme.textPrimary : AppTheme.textSecondary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              // Unlocked / Locked Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUnlocked ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isUnlocked ? 'Kazanıldı' : 'Kilitli',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: isUnlocked ? color : Colors.grey,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Neon Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.transparent,
                    color: color,
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
          if (!isUnlocked)
            const Positioned(
              right: 4,
              top: 4,
              child: Icon(
                Icons.lock_outline_rounded,
                color: Colors.grey,
                size: 16,
              ),
            ),
        ],
      ),
    );

    // Apply smooth gentle float/breathing animation to unlocked badges, and standard fade-in
    if (isUnlocked) {
      return GestureDetector(
        onTap: () => _showBadgeDetail(context, ach),
        child: cardChild
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .slideY(begin: 0, end: -0.04, duration: 2500.ms, curve: Curves.easeInOut)
            .animate()
            .shimmer(
              delay: 2.seconds,
              duration: 1800.ms,
              color: color.withValues(alpha: 0.15),
            ),
      );
    } else {
      return GestureDetector(
        onTap: () => _showBadgeDetail(context, ach),
        child: cardChild,
      );
    }
  }

  void _showBadgeDetail(BuildContext context, Map<String, dynamic> ach) {
    final isUnlocked = ach['isUnlocked'] as bool? ?? false;
    final progress = (ach['progress'] as num? ?? 0.0).toDouble();
    final color = _getBadgeColor(ach['colorName'] ?? '');
    final icon = _getBadgeIcon(ach['iconName'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            // Glowing Multi-Layered Large Icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked ? color.withValues(alpha: 0.25) : Colors.grey.withValues(alpha: 0.1),
                  width: 2.5,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: isUnlocked 
                    ? LinearGradient(
                        colors: [color, color.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.grey[200]!, Colors.grey[100]!],
                      ),
                  shape: BoxShape.circle,
                  boxShadow: isUnlocked ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 25,
                      spreadRadius: 3,
                    )
                  ] : null,
                ),
                child: Icon(
                  isUnlocked ? icon : Icons.lock_outline_rounded,
                  color: isUnlocked ? Colors.white : Colors.grey[500],
                  size: 48,
                ),
              ),
            ).animate(target: isUnlocked ? 1 : 0).scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              ach['title'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppTheme.textPrimary, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isUnlocked ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                isUnlocked ? 'KAZANILDI' : 'KİLİTLİ',
                style: TextStyle(
                  color: isUnlocked ? color : Colors.grey[600],
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              ach['description'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, height: 1.5, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 28),
            // Progress Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Prova İlerlemesi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
                Text('%${(progress * 100).toInt()}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 8,
                color: Colors.black.withValues(alpha: 0.04),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  color: color,
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUnlocked ? color : Colors.grey[800],
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: isUnlocked ? color.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Harika', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
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


