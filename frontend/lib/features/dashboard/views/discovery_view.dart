import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/glass_container.dart';
import 'package:persona_mirror/core/di/scenario_provider.dart';
import 'package:persona_mirror/core/models/scenario.dart';

class DiscoveryView extends ConsumerWidget {
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yeni Dünyalar Keşfet',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 8),
        const Text(
          'Başkalarının en çok zorlandığı durumları sen de deneyimle.',
          style: TextStyle(color: AppTheme.textSecondary),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 32),
        
        // Arama Çubuğu
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 20,
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: AppTheme.textTertiary),
              SizedBox(width: 12),
              Text('Senaryo ara...', style: TextStyle(color: AppTheme.textTertiary)),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
        
        const SizedBox(height: 32),

        templatesAsync.when(
          data: (templates) => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: templates.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final template = templates[index];
              return _buildDiscoveryCard(
                context,
                template,
                index,
              );
            },
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: AppTheme.accentViolet),
            ),
          ),
          error: (err, stack) => Center(
            child: Text('Hata: $err', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveryCard(
    BuildContext context,
    Scenario template,
    int index,
  ) {
    IconData icon;
    Color accentColor;

    switch (template.category) {
      case 'İş Hayatı':
        icon = Icons.work_rounded;
        accentColor = AppTheme.accentSky;
        break;
      case 'Arkadaşlık':
      case 'Sosyal':
        icon = Icons.people_rounded;
        accentColor = AppTheme.accentTeal;
        break;
      case 'Romantik':
        icon = Icons.favorite_rounded;
        accentColor = AppTheme.accentCoral;
        break;
      case 'Aile':
        icon = Icons.home_rounded;
        accentColor = Colors.orange;
        break;
      default:
        icon = Icons.explore_rounded;
        accentColor = AppTheme.accentViolet;
    }

    return GestureDetector(
      onTap: () => context.push('/create-scenario', extra: template),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.title, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(template.category, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.accentViolet.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => context.push('/create-scenario', extra: template),
                icon: const Icon(Icons.add_rounded, color: AppTheme.accentViolet),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (300 + (index * 100)).ms).slideX(begin: 0.05, end: 0),
    );
  }
}

