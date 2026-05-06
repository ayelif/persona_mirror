import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/spacing.dart';
import 'package:persona_mirror/core/glass_container.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          'Analiz Raporları',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          'Tüm geçmiş görüşmelerinin dökümü.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: AppSpacing.x3l),
        
        _buildStatCards(),
        const SizedBox(height: AppSpacing.x3l),
        
        const Text('Son Raporlar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        _buildReportList(),
      ],
    ).animate().fadeIn();
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        _StatCard(label: 'Toplam Prova', value: '24', icon: Icons.history_rounded, color: AppTheme.accentViolet),
        const SizedBox(width: 12),
        _StatCard(label: 'Ort. Skor', value: '%88', icon: Icons.insights_rounded, color: AppTheme.accentTeal),
      ],
    );
  }

  Widget _buildReportList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _ReportItem(
          title: index == 0 ? 'Maaş Artışı Talebi' : 'Müşteri Sunumu ${index + 1}',
          date: '14 May 2024',
          score: (95 - index * 3).toString(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.zero,
        backgroundColor: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: color)),
            Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ReportItem extends StatelessWidget {
  final String title;
  final String date;
  final String score;

  const _ReportItem({required this.title, required this.date, required this.score});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.bgSecondary, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.description_outlined, color: AppTheme.accentViolet),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(date, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text('%$score', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.accentTeal)),
        ],
      ),
    );
  }
}
