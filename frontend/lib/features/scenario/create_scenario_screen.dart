import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/models/scenario.dart';
import 'package:persona_mirror/core/di/scenario_provider.dart';
import 'package:persona_mirror/core/widgets/premium_background.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CreateScenarioScreen extends ConsumerStatefulWidget {
  final Scenario? template;
  const CreateScenarioScreen({super.key, this.template});

  @override
  ConsumerState<CreateScenarioScreen> createState() => _CreateScenarioScreenState();
}

class _CreateScenarioScreenState extends ConsumerState<CreateScenarioScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  final _titleController = TextEditingController();
  final _personaController = TextEditingController();
  final _contextController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _titleController.text = widget.template!.title;
      _contextController.text = widget.template!.context;
      _personaController.text = "Senaryo Şablonu: ${widget.template!.category}";
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutQuart);
    } else {
      _handleCreate();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutQuart);
    }
  }

  Future<void> _handleCreate() async {
    if (_titleController.text.isEmpty || _personaController.text.isEmpty || _contextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen tüm alanları doldurun.'),
          backgroundColor: AppTheme.statusError,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repository = ref.read(scenarioRepositoryProvider);
      
      final fullContext = "Karakter Profili: ${_personaController.text}\n\nSenaryo Detayları: ${_contextController.text}";

      final newScenario = await repository.createScenario(
        title: _titleController.text.trim(),
        context: fullContext,
        category: widget.template?.category ?? 'Özel',
      );
      
      ref.invalidate(scenariosProvider);

      if (mounted) {
        context.push('/simulation', extra: newScenario);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppTheme.statusError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentStep = idx),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildStepContent(
                      '🎯 Konu Nedir?',
                      'Neyi prova etmek istiyorsun?',
                      'Örn: Maaş Artışı Talebi...',
                      _titleController,
                      1,
                    ),
                    _buildStepContent(
                      '👤 Kiminle Konuşacaksın?',
                      'Karşındaki kişinin karakteri nasıl?',
                      'Örn: Sert bir yönetici...',
                      _personaController,
                      3,
                    ),
                    _buildStepContent(
                      '📝 Detaylar',
                      'Ortam nasıl? Hedefin ne?',
                      'Örn: Ofisteyiz, son 6 ayın performansını sunacağım...',
                      _contextController,
                      5,
                    ),
                  ],
                ),
              ),
              _buildBottomNav(),
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
            icon: Icon(
              _currentStep == 0 ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary,
            ),
            onPressed: _currentStep == 0 ? () => context.pop() : _prevStep,
          ),
          const SizedBox(width: 8),
          Text(
            widget.template != null ? 'Şablonu Özelleştir' : 'Senaryo Hazırla',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Stack(
        children: [
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.accentViolet.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            height: 8,
            width: MediaQuery.of(context).size.width * ((_currentStep + 1) / 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentViolet, AppTheme.accentSky],
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentViolet.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(String title, String subtitle, String hint, TextEditingController controller, int lines) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 40),
          TextField(
            controller: controller,
            maxLines: lines,
            style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppTheme.textTertiary),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppTheme.accentViolet, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(24),
            ),
          ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adım ${_currentStep + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary),
              ),
              const Text(
                'Hazırlığa devam et',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
          _isLoading 
            ? const SizedBox(width: 60, height: 60, child: Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.accentViolet),
              ))
            : ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentViolet,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  shadowColor: AppTheme.accentViolet.withValues(alpha: 0.4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentStep == 2 ? 'Provayı Başlat' : 'Devam Et',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Icon(_currentStep == 2 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).scale(),
        ],
      ),
    );
  }
}


