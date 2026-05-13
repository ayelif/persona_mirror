import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme/app_theme.dart';
import 'package:persona_mirror/core/models/scenario.dart';
import 'package:persona_mirror/core/di/scenario_provider.dart';

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
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _handleCreate();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _handleCreate() async {
    if (_titleController.text.isEmpty || _personaController.text.isEmpty || _contextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen tüm alanları doldurun.')));
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
      
      // Senaryo listesini yenile
      ref.invalidate(scenariosProvider);

      if (mounted) {
        context.push('/simulation', extra: newScenario);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.template != null ? 'Şablonu Özelleştir' : 'Senaryo Hazırla'),
        leading: IconButton(
          icon: Icon(_currentStep == 0 ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded),
          onPressed: _currentStep == 0 ? () => context.pop() : _prevStep,
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentStep = idx),
              physics: const NeverScrollableScrollPhysics(),
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
    );
  }

  Widget _buildProgressIndicator() {
    return LinearProgressIndicator(
      value: (_currentStep + 1) / 3,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
      minHeight: 6,
    );
  }

  Widget _buildStepContent(String title, String subtitle, String hint, TextEditingController controller, int lines) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: AppTheme.mutedTextColor)),
          const SizedBox(height: 32),
          TextField(
            controller: controller,
            maxLines: lines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Adım ${_currentStep + 1} / 3', style: const TextStyle(fontWeight: FontWeight.w500)),
          _isLoading 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                child: Text(_currentStep == 2 ? 'Başlat' : 'Devam Et'),
              ),
        ],
      ),
    );
  }
}

