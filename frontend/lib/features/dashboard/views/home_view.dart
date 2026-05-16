import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persona_mirror/core/di/scenario_provider.dart';
import 'package:persona_mirror/core/models/scenario.dart';
import 'package:persona_mirror/core/glass_container.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenariosProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.email?.split('@')[0] ?? 'Sarah Miller';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, userName).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 24),
        
        // 1. ÜST KISIM: HIZLI BAŞLAT
        _buildSectionHeader('Hızlı Başlat', 'Hemen bir simülasyona gir.')
            .animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        _buildQuickStartRow(context, ref)
            .animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: 32),
        
        // 2. ORTA KISIM: GEÇMİŞ SENARYOLAR
        _buildSectionHeader('Aktif Senaryolar', 'Senin için hazırlanan özel çalışmalar.')
            .animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 16),
        scenariosAsync.when(
          data: (scenarios) => scenarios.isEmpty 
              ? _buildEmptyState()
              : _buildScenarioList(context, scenarios),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text('Hata: $e', style: const TextStyle(color: AppTheme.statusError)),
          ),
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: 32),
        
        // 3. ALT KISIM: DUYGU DURUM VE PERFORMANS
        _buildSectionHeader('Mood & Performance', 'Gelişimini takip et.')
            .animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 20),
        _buildMoodMetricsRow(ref).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hoş Geldin,', style: TextStyle(fontSize: 14, color: AppTheme.textTertiary)),
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ],
        ),
        GestureDetector(
          onTap: () => context.push('/settings'),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.accentViolet, AppTheme.accentSky],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_rounded, color: AppTheme.accentViolet, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStartRow(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);

    return templatesAsync.when(
      data: (templates) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        child: Row(
          children: templates.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _QuickActionCard(
              title: entry.value.title,
              subtitle: entry.value.category,
              icon: _getIconForCategory(entry.value.category),
              color: _getColorForCategory(entry.value.category),
              onTap: () => context.push('/create-scenario', extra: entry.value),
            ).animate().fadeIn(delay: (300 + (entry.key * 100)).ms).scale(begin: const Offset(0.9, 0.9)),
          )).toList(),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Hata: $e'),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'İş Hayatı': return Icons.work_rounded;
      case 'Arkadaşlık': return Icons.people_rounded;
      case 'Romantik': return Icons.favorite_rounded;
      default: return Icons.psychology_rounded;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'İş Hayatı': return AppTheme.accentViolet;
      case 'Arkadaşlık': return AppTheme.accentPurple;
      case 'Romantik': return AppTheme.accentCoral;
      default: return AppTheme.accentTeal;
    }
  }


  Widget _buildScenarioList(BuildContext context, List<Scenario> scenarios) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scenarios.length,
      itemBuilder: (context, index) {
        final scenario = scenarios[index];
        return Consumer(
          builder: (context, ref, child) => Dismissible(
            key: Key(scenario.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Senaryoyu Sil'),
                  content: const Text('Bu senaryoyu ve buna bağlı tüm analizleri silmek istediğine emin misin?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true), 
                      style: TextButton.styleFrom(foregroundColor: AppTheme.statusError),
                      child: const Text('Sil'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) async {
              await ref.read(scenarioRepositoryProvider).deleteScenario(scenario.id);
              ref.invalidate(scenariosProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senaryo silindi')));
              }
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.statusError.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: AppTheme.statusError),
            ),
            child: AppCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getColorForCategory(scenario.category ?? '').withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Icon(
                    _getIconForCategory(scenario.category ?? ''),
                    color: _getColorForCategory(scenario.category ?? ''),
                    size: 24
                  ),
                ),
                title: Text(scenario.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary)),
                subtitle: Text(scenario.context, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textTertiary),
                onTap: () => context.push('/simulation', extra: scenario),
              ),
            ),
          ),
        ).animate().fadeIn(delay: (500 + (index * 50)).ms).slideX(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildMoodMetricsRow(WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: statsAsync.when(
        data: (stats) {
          final skills = stats['skills'] as Map? ?? {};
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MoodMetric(label: 'Empati', value: (skills['Empati'] ?? 0.0).toDouble(), color: AppTheme.accentCoral),
              _MoodMetric(label: 'Netlik', value: (skills['Netlik'] ?? 0.0).toDouble(), color: AppTheme.accentSky),
              _MoodMetric(label: 'Kararlılık', value: (skills['Kararlılık'] ?? 0.0).toDouble(), color: AppTheme.accentTeal),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('Henüz bir senaryon yok.', style: TextStyle(color: AppTheme.textTertiary)),
      ),
    );
  }
}

class _MoodMetric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MoodMetric({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text('${(value * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.shadowCard,
          border: Border.all(color: AppTheme.borderLight, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

