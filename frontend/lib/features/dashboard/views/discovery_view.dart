import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:persona_mirror/core/theme/app_theme.dart';

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
        ),
        const SizedBox(height: 8),
        const Text(
          'Başkalarının en çok zorlandığı durumları sen de deneyimle.',
          style: TextStyle(color: AppTheme.mutedTextColor),
        ),
        const SizedBox(height: 32),
        
        // Arama Çubuğu (Görsel olarak)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: AppTheme.glassDecoration,
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: AppTheme.mutedTextColor),
              SizedBox(width: 12),
              Text('Senaryo ara...', style: TextStyle(color: AppTheme.mutedTextColor)),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        _buildDiscoveryCard(
          context,
          'Maaş Zammı İstemek',
          'İş Dünyası',
          Icons.payments_outlined,
          const Color(0xFFE3F2FD),
          const Color(0xFF1E88E5),
        ),
        const SizedBox(height: 16),
        _buildDiscoveryCard(
          context,
          'Zor Bir Ayrılık Konuşması',
          'İlişkiler',
          Icons.favorite_outline_rounded,
          const Color(0xFFFCE4EC),
          const Color(0xFFD81B60),
        ),
        const SizedBox(height: 16),
        _buildDiscoveryCard(
          context,
          'Yeni Bir Takıma Liderlik',
          'Yönetim',
          Icons.leaderboard_outlined,
          const Color(0xFFE8F5E9),
          const Color(0xFF43A047),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildDiscoveryCard(
    BuildContext context,
    String title,
    String category,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(category, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }
}
