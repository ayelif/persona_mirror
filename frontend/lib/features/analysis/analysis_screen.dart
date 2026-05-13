import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme/app_theme.dart';
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
    try {
      final response = await Supabase.instance.client.functions.invoke('analyses', body: {
        'session_id': widget.sessionId,
      });
      
      if (mounted) {
        setState(() {
          _analysisData = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Analiz Raporu'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Hata: $_error'))
              : _buildContent(context, _analysisData!),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildScoreCard(context, data),
          const SizedBox(height: 24),
          _buildAnalysisSection('Özet', data['summary'] ?? '', Icons.summarize_outlined, Colors.blue),
          const SizedBox(height: 16),
          _buildListSection('Güçlü Yanların', data['strengths'] ?? [], Icons.trending_up, Colors.green),
          const SizedBox(height: 16),
          _buildListSection('Gelişim Alanların', data['improvements'] ?? [], Icons.track_changes, Colors.orange),
          const SizedBox(height: 16),
          _buildListSection('Alternatif İfadeler', data['alternative_lines'] ?? [], Icons.chat_bubble_outline, Colors.purple),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          const Text('Performans Skorların', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetric('Empati', (data['empathy_score'] ?? 0).toDouble()),
              _buildMetric('Netlik', (data['clarity_score'] ?? 0).toDouble()),
              _buildMetric('Kararlılık', (data['assertiveness_score'] ?? 0).toDouble()),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildMetric(String label, double score) {
    final color = score >= 7 ? Colors.green : (score >= 4 ? Colors.orange : Colors.red);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: score / 10,
                strokeWidth: 6,
                color: color,
                backgroundColor: color.withOpacity(0.1),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text('${score.toInt()}/10', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.mutedTextColor)),
      ],
    );
  }

  Widget _buildAnalysisSection(String title, String content, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(height: 1.6, color: AppTheme.textColor)),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildListSection(String title, dynamic items, IconData icon, Color color) {
    final List listItems = items is List ? items : [];
    if (listItems.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ...listItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 6, color: AppTheme.mutedTextColor),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(item.toString(), style: const TextStyle(color: AppTheme.textColor))),
              ],
            ),
          )),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

}
