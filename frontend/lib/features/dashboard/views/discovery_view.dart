import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/spacing.dart';
import 'package:persona_mirror/core/glass_container.dart';

class DiscoveryView extends StatelessWidget {
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          'Senaryo Keşfet',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          'Pratik yapmak istediğin alanı seç.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: AppSpacing.x3l),
        
        _buildSearchField(),
        const SizedBox(height: AppSpacing.x3l),
        
        _buildCategorySection(context, 'Popüler', [
          _ScenarioCard(title: 'Maaş Pazarlığı', category: 'İş', icon: Icons.payments_outlined, color: AppTheme.accentViolet),
          _ScenarioCard(title: 'Zor Müşteri', category: 'Satış', icon: Icons.support_agent_rounded, color: AppTheme.accentCoral),
        ]),
        const SizedBox(height: AppSpacing.x3l),
        
        _buildCategorySection(context, 'İletişim', [
          _ScenarioCard(title: 'Hayır Demek', category: 'Sosyal', icon: Icons.block_flipped, color: AppTheme.accentTeal),
          _ScenarioCard(title: 'Geri Bildirim', category: 'Yönetim', icon: Icons.comment_bank_outlined, color: AppTheme.accentSky),
        ]),
      ],
    ).animate().fadeIn();
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowSm,
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Senaryo veya kategori ara...',
          prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textTertiary),
          border: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String title, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        Row(
          children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList(),
        ),
      ],
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final String title;
  final String category;
  final IconData icon;
  final Color color;

  const _ScenarioCard({required this.title, required this.category, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/create-scenario'),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.zero,
        backgroundColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(category, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
