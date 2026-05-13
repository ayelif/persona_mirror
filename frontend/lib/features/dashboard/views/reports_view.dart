import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:persona_mirror/core/theme/app_theme.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gelişim Yolculuğun',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        const Text(
          'AI tarafından analiz edilen tüm konuşmalarının özeti.',
          style: TextStyle(color: AppTheme.mutedTextColor),
        ),
        const SizedBox(height: 32),
        
        // Özet İstatistikler
        Row(
          children: [
            _buildStatCard('Toplam Prova', '12', Icons.chat_bubble_outline),
            const SizedBox(width: 16),
            _buildStatCard('Ort. Skor', '84', Icons.star_outline_rounded),
          ],
        ),
        
        const SizedBox(height: 40),
        const Text('Yetenek Grafiğin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        
        // Yetenek Kartları
        _buildSkillProgress('Empati', 0.85, Colors.pinkAccent),
        const SizedBox(height: 12),
        _buildSkillProgress('Netlik', 0.65, Colors.blueAccent),
        const SizedBox(height: 12),
        _buildSkillProgress('Kararlılık', 0.92, Colors.teal),
        
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.glassDecoration.copyWith(
            color: AppTheme.primaryColor.withOpacity(0.05),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryColor),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Harika gidiyorsun! Son 3 provanda empati skorun %15 arttı.',
                  style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ).animate().shimmer(delay: 2.seconds),
      ],
    ).animate().fadeIn();
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillProgress(String label, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('%${(progress * 100).toInt()}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            color: color,
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}
