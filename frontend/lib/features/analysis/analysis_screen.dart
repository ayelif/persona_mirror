import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/spacing.dart';

import 'package:persona_mirror/core/glass_container.dart';


class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppLayout.screenPaddingH),
              child: Column(
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  _buildScoreSection(context),
                  const SizedBox(height: 24),
                  _buildDetailedFeedback(context),
                  const SizedBox(height: 24),
                  _buildAlternativeLines(context),
                  const SizedBox(height: 40),
                  _buildActionButtons(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      backgroundColor: AppTheme.bgPrimary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Analiz Raporu',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        background: Stack(
          children: [
            Positioned(
              right: -50,
              top: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: AppTheme.accentViolet.withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: AppTheme.accentViolet),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentViolet.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentViolet, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Genel Değerlendirme',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Konuşma boyunca dengeli bir tutum sergiledin. Empati kurma yeteneğin oldukça yüksekti ancak bazı noktalarda netliğini artırarak daha kararlı bir duruş sergileyebilirsin.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildScoreSection(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetric(context, 'Empati', 0.85, AppTheme.accentViolet),
              _buildMetric(context, 'Netlik', 0.70, AppTheme.accentSky),
              _buildMetric(context, 'Kararlılık', 0.90, AppTheme.accentTeal),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildMetric(BuildContext context, String label, double score, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 72,
              width: 72,
              child: CircularProgressIndicator(
                value: score,
                strokeWidth: 8,
                backgroundColor: color.withValues(alpha: 0.1),
                color: color,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '%${(score * 100).toInt()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDetailedFeedback(BuildContext context) {
    return Column(
      children: [
        _buildFeedbackItem(
          context,
          'Güçlü Yanların',
          Icons.verified_rounded,
          AppTheme.accentTeal,
          [
            'Karşı tarafın duygularını iyi analiz ettin.',
            'Sakin ve profesyonel bir dil kullandın.',
          ],
        ),
        const SizedBox(height: 16),
        _buildFeedbackItem(
          context,
          'Gelişim Alanları',
          Icons.lightbulb_rounded,
          AppTheme.accentGold,
          [
            'Bazı cevapların gereğinden uzun ve dolaylıydı.',
            'Maaş beklentini dile getirirken daha spesifik olmalısın.',
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildFeedbackItem(BuildContext context, String title, IconData icon, Color color, List<String> items) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppTheme.textTertiary)),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAlternativeLines(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Şunu da diyebilirdin...',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildAlternativeLine(
            'Senin cümlen: "Aslında zam konusunu bir düşünmenizi istiyorum."',
            'Önerimiz: "Son 1 yıldaki performansım ve sektör ortalaması doğrultusunda %30\'luk bir artış talep ediyorum."',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildAlternativeLine(String oldText, String newText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          oldText,
          style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accentViolet.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentViolet.withValues(alpha: 0.1)),
          ),
          child: Text(
            newText,
            style: const TextStyle(fontSize: 14, color: AppTheme.accentViolet, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppTheme.borderMedium),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Tekrar Dene', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => context.go('/dashboard'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.accentViolet, AppTheme.accentPurple]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.glowViolet,
              ),
              child: const Center(
                child: Text('Tamamla', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
