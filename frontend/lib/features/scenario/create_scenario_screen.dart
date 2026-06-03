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
  String _selectedGender = 'female'; // Default to female voice/character

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
      
      // Store selected gender right inside the context dynamically!
      final fullContext = "Cinsiyet: ${_selectedGender == 'female' ? 'Kadın' : 'Erkek'}\nKarakter Profili: ${_personaController.text}\n\nSenaryo Detayları: ${_contextController.text}";

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

  final List<String> _topicOptions = [
    'Maaş Zammı', 'Terfi Talebi', 'İstifa Konuşması', 'Sınır Koyma', 
    'Borç İsteme', 'Ayrılık', 'Özür Dileme', 'Tartışma Çözümü', 'Geri Bildirim'
  ];

  final List<String> _traitOptions = [
    'Sert ve Otoriter', 'İnatçı', 'Duygusal', 'Mantıklı ve Analitik', 
    'Sabırsız', 'Şüpheci', 'Uzlaşmacı', 'Empatik', 'Savunmacı', 'Sakin'
  ];

  void _onOptionSelected(TextEditingController controller, String option, bool isMulti) {
    setState(() {
      if (isMulti) {
        final currentText = controller.text;
        if (currentText.contains(option)) {
          // Remove if already exists (toggle)
          controller.text = currentText.replaceFirst(currentText.contains(', $option') ? ', $option' : (currentText.startsWith(option) && currentText.contains(', ') ? '$option, ' : option), '').trim();
        } else {
          // Add
          if (currentText.isEmpty) {
            controller.text = option;
          } else {
            controller.text = '$currentText, $option';
          }
        }
      } else {
        controller.text = option;
      }
    });
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
                      _topicOptions,
                      false,
                    ),
                    _buildStepContent(
                      '👤 Kiminle Konuşacaksın?',
                      'Karşındaki kişinin karakteri nasıl?',
                      'Örn: Sert bir yönetici...',
                      _personaController,
                      3,
                      _traitOptions,
                      true,
                    ),
                    _buildStepContent(
                      '📝 Detaylar',
                      'Ortam nasıl? Hedefin ne?',
                      'Örn: Ofisteyiz, son 6 ayın performansını sunacağım...',
                      _contextController,
                      5,
                      null,
                      false,
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

  Widget _buildStepContent(String title, String subtitle, String hint, TextEditingController controller, int lines, List<String>? options, bool isMulti) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -1),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.8), fontSize: 16, height: 1.4),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 40),
          
          // TextField with custom styling
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentViolet.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              maxLines: lines,
              style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppTheme.textTertiary),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppTheme.accentViolet, width: 2),
                ),
                contentPadding: const EdgeInsets.all(24),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.98, 0.98)),

          if (options != null) ...[
            const SizedBox(height: 48),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.accentViolet,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isMulti ? 'Kişilik Özelliklerini Belirle' : 'Popüler Konulardan Seç',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textPrimary, fontSize: 15, letterSpacing: 0.2),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 14,
              children: List.generate(options.length, (index) {
                final opt = options[index];
                final isSelected = controller.text.contains(opt);
                return _buildAestheticChip(
                  label: opt,
                  isSelected: isSelected,
                  onTap: () => _onOptionSelected(controller, opt, isMulti),
                  index: index,
                );
              }),
            ),
          ],
          if (title.contains('👤 Kiminle Konuşacaksın?')) ...[
            const SizedBox(height: 32),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.accentViolet,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ses ve Karakter Cinsiyeti',
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textPrimary, fontSize: 15, letterSpacing: 0.2),
                ),
              ],
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGenderCard('Kadın', Icons.female_rounded, _selectedGender == 'female', () {
                    setState(() => _selectedGender = 'female');
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGenderCard('Erkek', Icons.male_rounded, _selectedGender == 'male', () {
                    setState(() => _selectedGender = 'male');
                  }),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildGenderCard(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    final color = label == 'Kadın' ? AppTheme.accentViolet : AppTheme.accentSky;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.8),
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: isSelected ? color : AppTheme.textTertiary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAestheticChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required int index,
  }) {
    IconData icon;
    // Map icons based on label
    switch (label) {
      case 'Maaş Zammı': icon = Icons.payments_outlined; break;
      case 'Terfi Talebi': icon = Icons.trending_up_outlined; break;
      case 'İstifa Konuşması': icon = Icons.exit_to_app_outlined; break;
      case 'Sınır Koyma': icon = Icons.security_outlined; break;
      case 'Borç İsteme': icon = Icons.request_quote_outlined; break;
      case 'Ayrılık': icon = Icons.heart_broken_outlined; break;
      case 'Özür Dileme': icon = Icons.sentiment_very_satisfied_outlined; break;
      case 'Tartışma Çözümü': icon = Icons.handshake_outlined; break;
      case 'Geri Bildirim': icon = Icons.comment_outlined; break;
      case 'Sert ve Otoriter': icon = Icons.gavel_outlined; break;
      case 'İnatçı': icon = Icons.block_outlined; break;
      case 'Duygusal': icon = Icons.favorite_outlined; break;
      case 'Mantıklı ve Analitik': icon = Icons.psychology_outlined; break;
      case 'Sabırsız': icon = Icons.timer_outlined; break;
      case 'Şüpheci': icon = Icons.search_outlined; break;
      case 'Uzlaşmacı': icon = Icons.thumbs_up_down_outlined; break;
      case 'Empatik': icon = Icons.emoji_emotions_outlined; break;
      case 'Savunmacı': icon = Icons.shield_outlined; break;
      case 'Sakin': icon = Icons.self_improvement_outlined; break;
      default: icon = Icons.auto_awesome_outlined;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentViolet : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.accentViolet : Colors.white.withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.accentViolet.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppTheme.accentViolet,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (400 + (index * 50)).ms).scale(begin: const Offset(0.9, 0.9)),
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


