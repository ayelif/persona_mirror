import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persona_mirror/core/di/scenario_provider.dart';
import 'package:persona_mirror/core/models/scenario.dart';
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
        _buildHeader(context, userName),
        const SizedBox(height: 24),
        
        // 1. ÜST KISIM: HIZLI BAŞLAT
        _buildSectionHeader('Hızlı Başlat', 'Hemen bir simülasyona gir.'),
        const SizedBox(height: 16),
        _buildQuickStartRow(context, ref),
        const SizedBox(height: 32),
        
        // 2. ORTA KISIM: GEÇMİŞ SENARYOLAR
        _buildSectionHeader('Aktif Senaryolar', 'Senin için hazırlanan özel çalışmalar.'),
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
            child: Text('Hata: $e', style: const TextStyle(color: Colors.red)),
          ),
        ),
        const SizedBox(height: 32),
        
        // 3. ALT KISIM: DUYGU DURUM VE PERFORMANS
        _buildSectionHeader('Mood & Performance', 'Gelişimini takip et.'),
        const SizedBox(height: 20),
        _buildMoodMetricsRow(),
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
            const Text('Hoş Geldin,', style: TextStyle(fontSize: 14, color: AppTheme.mutedTextColor)),
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
          ],
        ),
        GestureDetector(
          onTap: () => context.push('/settings'),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: const Icon(Icons.person_rounded, color: AppTheme.primaryColor, size: 28),
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
          children: templates.map((template) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _QuickActionCard(
              title: template.title,
              subtitle: template.category,
              icon: _getIconForCategory(template.category),
              color: _getColorForCategory(template.category),
              onTap: () => context.push('/create-scenario', extra: template),
            ),
          )).toList(),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Hata: $e'),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'İş Hayatı': return Icons.work_outline_rounded;
      case 'Arkadaşlık': return Icons.people_outline_rounded;
      case 'Romantik': return Icons.favorite_border_rounded;
      default: return Icons.psychology_outlined;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'İş Hayatı': return AppTheme.primaryColor;
      case 'Arkadaşlık': return Colors.purple;
      case 'Romantik': return Colors.orange;
      default: return AppTheme.accentColor;
    }
  }


  Widget _buildScenarioList(BuildContext context, List<Scenario> scenarios) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scenarios.length,
      itemBuilder: (context, index) {
        final scenario = scenarios[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppTheme.glassDecoration,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.psychology_outlined, color: AppTheme.primaryColor, size: 24),
            ),
            title: Text(scenario.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(scenario.context, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.mutedTextColor),
            onTap: () => context.push('/simulation', extra: scenario),
          ),
        );
      },
    );
  }

  Widget _buildMoodMetricsRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MoodMetric(label: 'Empati', value: 0.85, color: Colors.pinkAccent),
          _MoodMetric(label: 'Netlik', value: 0.65, color: Colors.blueAccent),
          _MoodMetric(label: 'Kararlılık', value: 0.92, color: Colors.teal),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.mutedTextColor)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('Henüz bir senaryon yok.', style: TextStyle(color: AppTheme.mutedTextColor)),
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
                strokeWidth: 5,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text('${(value * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.mutedTextColor)),
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
        width: 155,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.mutedTextColor)),
          ],
        ),
      ),
    );
  }
}
