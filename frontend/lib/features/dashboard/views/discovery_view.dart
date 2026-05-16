import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/glass_container.dart';

class DiscoveryView extends StatelessWidget {
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
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
        _buildDiscoveryCard(
          context,
          'Maaş Zammı İstemek',
          'İş Dünyası',
          Icons.payments_rounded,
          AppTheme.accentSky,
          0,
        ),
        const SizedBox(height: 16),
        _buildDiscoveryCard(
          context,
          'Zor Bir Ayrılık Konuşması',
          'İlişkiler',
          Icons.favorite_rounded,
          AppTheme.accentCoral,
          1,
        ),
        const SizedBox(height: 16),
        _buildDiscoveryCard(
          context,
          'Yeni Bir Takıma Liderlik',
          'Yönetim',
          Icons.leaderboard_rounded,
          AppTheme.accentTeal,
          2,
        ),
      ],
    );
  }

  Widget _buildDiscoveryCard(
    BuildContext context,
    String title,
    String category,
    IconData icon,
    Color accentColor,
    int index,
  ) {
    return AppCard(
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(category, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.accentViolet.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, color: AppTheme.accentViolet),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (300 + (index * 100)).ms).slideX(begin: 0.05, end: 0);
  }
}

