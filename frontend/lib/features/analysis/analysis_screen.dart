import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/glass_container.dart';
import 'package:persona_mirror/core/widgets/premium_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalysisScreen extends StatefulWidget {
  final String sessionId;
  const AnalysisScreen({super.key, required this.sessionId});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  Map<String, dynamic>? _analysisData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  Future<void> _fetchAnalysis() async {
    if (widget.sessionId.isEmpty) {
      setState(() {
        _error = "Oturum kimliği (session_id) bulunamadı.";
        _isLoading = false;
      });
      return;
    }

    try {
      // Hem query parameter hem de body olarak göndererek şansı artırıyoruz
      final response = await Supabase.instance.client.functions.invoke(
        'analyses?session_id=${widget.sessionId}', 
        body: {'session_id': widget.sessionId},
      );
      
      if (mounted) {
        setState(() {
          _analysisData = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Analiz Hatası: $e');
      if (mounted) {
        setState(() {
          _error = e.toString().contains('400') 
              ? "Analiz henüz hazır değil veya oturum bilgisi eksik." 
              : "Bağlantı hatası oluştu.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _error != null
                        ? _buildErrorState()
                        : _buildContent(context, _analysisData!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppTheme.textPrimary),
            onPressed: () => context.go('/dashboard'),
          ),
          const SizedBox(width: 8),
          const Text(
            'Analiz Raporu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.accentViolet),
          const SizedBox(height: 24),
          const Text(
            'AI Analizi Hazırlanıyor...',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
          const SizedBox(height: 8),
          const Text(
            'Konuşman değerlendiriliyor, lütfen bekle.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.statusError),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Bilinmeyen bir hata oluştu',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchAnalysis();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentViolet),
              child: const Text('Tekrar Dene', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildScoreCard(context, data),
          const SizedBox(height: 24),
          _buildAnalysisSection('Özet', data['summary'] ?? '', Icons.summarize_rounded, AppTheme.accentSky),
          const SizedBox(height: 16),
          _buildListSection('Güçlü Yanların', data['strengths'] ?? [], Icons.trending_up_rounded, AppTheme.accentTeal),
          const SizedBox(height: 16),
          _buildListSection('Gelişim Alanların', data['improvements'] ?? [], Icons.track_changes_rounded, AppTheme.accentCoral),
          const SizedBox(height: 16),
          _buildListSection('Alternatif İfadeler', data['alternative_lines'] ?? [], Icons.chat_bubble_outline_rounded, AppTheme.accentPurple),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentViolet,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Ana Sayfaya Dön', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, Map<String, dynamic> data) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('Performans Skorların', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.textPrimary)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetric('Empati', (data['empathy_score'] ?? 0).toDouble(), AppTheme.accentCoral),
              _buildMetric('Netlik', (data['clarity_score'] ?? 0).toDouble(), AppTheme.accentSky),
              _buildMetric('Kararlılık', (data['assertiveness_score'] ?? 0).toDouble(), AppTheme.accentTeal),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildMetric(String label, double score, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                value: score / 10,
                strokeWidth: 7,
                color: color,
                backgroundColor: color.withValues(alpha: 0.1),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '${score.toInt()}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildAnalysisSection(String title, String content, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          Text(content, style: const TextStyle(height: 1.6, color: AppTheme.textPrimary, fontSize: 15)),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildListSection(String title, dynamic items, IconData icon, Color color) {
    final List listItems = items is List ? items : [];
    if (listItems.isEmpty) return const SizedBox.shrink();

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ...listItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(Icons.auto_awesome_rounded, size: 14, color: color.withValues(alpha: 0.5)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(item.toString(), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.5))),
              ],
            ),
          )),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

}

