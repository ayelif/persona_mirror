import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/widgets/premium_background.dart';
import 'package:persona_mirror/core/models/scenario.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/glass_container.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:persona_mirror/features/simulation/providers/simulation_provider.dart';

class SimulationScreen extends ConsumerStatefulWidget {
  final Scenario scenario;
  const SimulationScreen({super.key, required this.scenario});

  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _localTransitionLoading = false;

  String _selectedDifficulty = 'medium';

  // Voice Mode Settings
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isSoundOn = true;

  @override
  void initState() {
    super.initState();
    _initVoiceSettings();
    // Reset state when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(simulationProvider(widget.scenario.id).notifier).reset();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initVoiceSettings() async {
    try {
      _speechEnabled = await _speech.initialize(
        onError: (val) => debugPrint('Speech init error: $val'),
        onStatus: (val) => debugPrint('Speech status: $val'),
      );
      setState(() {});
    } catch (e) {
      debugPrint('Speech init failed: $e');
    }

    try {
      await _tts.setLanguage('tr-TR');
      await _tts.setSpeechRate(0.5); // Natural rate
      await _tts.setVolume(1.0);
    } catch (e) {
      debugPrint('TTS init failed: $e');
    }
  }

  Future<void> _speak(String text) async {
    if (!_isSoundOn) return;
    try {
      final simState = ref.read(simulationProvider(widget.scenario.id));
      final isMale = widget.scenario.context.contains('Cinsiyet: Erkek');
      double basePitch = isMale ? 0.85 : 1.2;
      double baseRate = 0.5;

      // Dynamic speech parameters based on character mood & stress level!
      if (simState.currentMood == 'agitated' || simState.currentMood == 'frustrated') {
        baseRate = 0.58;
        basePitch *= 1.1; // Make it more tense (higher pitch)
      } else if (simState.currentMood == 'defensive') {
        baseRate = 0.53;
        basePitch *= 1.05;
      } else if (simState.currentMood == 'satisfied') {
        baseRate = 0.48;
        basePitch *= 0.95; // More relaxed (lower pitch)
      }

      await _tts.setSpeechRate(baseRate);
      await _tts.setPitch(basePitch);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speak failed: $e');
    }
  }

  void _startListening() async {
    if (!_speechEnabled) {
      await _initVoiceSettings();
      if (!_speechEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mikrofon servisi başlatılamadı veya izni verilmedi.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    setState(() => _isListening = true);

    try {
      await _speech.listen(
        onResult: (val) {
          setState(() {
            _messageController.text = val.recognizedWords;
          });
        },
        localeId: 'tr_TR', // Turkish Speech Recognition
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('Speech listen failed: $e');
      setState(() => _isListening = false);
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _startSimulation() async {
    ref.read(simulationProvider(widget.scenario.id).notifier).setDifficulty(_selectedDifficulty);
    
    try {
      await ref.read(simulationProvider(widget.scenario.id).notifier).startSimulation(widget.scenario.id);
      final simState = ref.read(simulationProvider(widget.scenario.id));
      if (simState.messages.isNotEmpty) {
        _speak(simState.messages.first['content']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bağlantı Hatası: $e'),
            backgroundColor: AppTheme.statusError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final simState = ref.read(simulationProvider(widget.scenario.id));
    final userTurns = simState.messages.where((m) => m['role'] == 'user').length;
    if (userTurns >= 8 || text.isEmpty || simState.sessionId == null || simState.isAITyping) return;

    _messageController.clear();
    // Stop any active TTS reading if user interrupts by typing/sending a reply
    _tts.stop();

    _scrollToBottom();

    try {
      final reply = await ref.read(simulationProvider(widget.scenario.id).notifier).sendMessage(text);
      if (mounted) {
        _speak(reply);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cevap alınamadı, lütfen tekrar deneyin.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  Future<void> _confirmEndSimulation() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Simülasyonu Bitir?', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        content: const Text('Bu oturumu sonlandırmak ve analiz almak istiyor musunuz?', style: TextStyle(color: AppTheme.textSecondary)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Devam Et', style: TextStyle(color: AppTheme.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentViolet,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Bitir ve Analiz Et', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      _endSimulation();
    }
  }

  Future<void> _endSimulation() async {
    final simState = ref.read(simulationProvider(widget.scenario.id));
    if (simState.sessionId == null || simState.isLoading) return;
    
    setState(() => _localTransitionLoading = true);
    try {
      await ref.read(simulationProvider(widget.scenario.id).notifier).endSimulation();
      if (mounted) {
        context.go('/analysis', extra: simState.sessionId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Analiz hazırlanırken hata: $e')));
        context.go('/analysis', extra: simState.sessionId);
      }
    } finally {
      if (mounted) setState(() => _localTransitionLoading = false);
    }
  }

  Future<void> _getMentorHint() async {
    final simState = ref.read(simulationProvider(widget.scenario.id));
    if (simState.sessionId == null || simState.isHintLoading) return;
    try {
      await ref.read(simulationProvider(widget.scenario.id).notifier).getMentorHint();
      final updatedState = ref.read(simulationProvider(widget.scenario.id));
      if (updatedState.currentHint != null && mounted) {
        _showHintDialog(updatedState.currentHint!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İpucu alınamadı: $e'), backgroundColor: AppTheme.statusError),
        );
      }
    }
  }

  void _showHintDialog(Map<String, String> hint) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb_rounded, color: AppTheme.accentGold),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Mentor Tavsiyesi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'İPUCU',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textTertiary, letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              Text(
                hint['tip']!,
                style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary, height: 1.5),
              ),
              const SizedBox(height: 20),
              const Text(
                'ÖNERİLEN CÜMLE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textTertiary, letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentViolet.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentViolet.withValues(alpha: 0.1)),
                ),
                child: Text(
                  hint['suggested_reply']!,
                  style: const TextStyle(fontSize: 14, color: AppTheme.accentViolet, fontStyle: FontStyle.italic, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Kapat', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _messageController.text = hint['suggested_reply']!;
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentViolet,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Kullan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'satisfied': return '😊';
      case 'defensive': return '🛡️';
      case 'frustrated': return '😥';
      case 'agitated': return '⚡';
      default: return '😐';
    }
  }

  String _getMoodText(String mood) {
    switch (mood) {
      case 'satisfied': return 'Yumuşamış / Memnun';
      case 'defensive': return 'Savunmacı';
      case 'frustrated': return 'Hayal Kırıklığı';
      case 'agitated': return 'Gergin / Sinirli';
      default: return 'Dengeli / Sakin';
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'satisfied': return AppTheme.accentGreen;
      case 'defensive': return AppTheme.accentCoral;
      case 'frustrated': return AppTheme.accentSky;
      case 'agitated': return AppTheme.accentPurple;
      default: return AppTheme.accentViolet;
    }
  }

  Widget _buildPersonaStatusPanel(SimulationState simState) {
    final moodColor = _getMoodColor(simState.currentMood);
    final userTurns = simState.messages.where((m) => m['role'] == 'user').length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji Avatar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: moodColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              _getMoodEmoji(simState.currentMood),
              style: const TextStyle(fontSize: 24),
            ),
          ).animate(target: simState.currentMood.hashCode.toDouble()).shake(duration: 500.ms),
          const SizedBox(width: 16),
          // Durum Detayları
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hamle: $userTurns/8',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Stres: ${simState.currentStressLevel}/10',
                      style: TextStyle(fontSize: 11, color: simState.currentStressLevel > 6 ? AppTheme.statusError : AppTheme.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getMoodText(simState.currentMood),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: moodColor),
                ),
                const SizedBox(height: 8),
                // Stres Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: simState.currentStressLevel / 10,
                    minHeight: 5,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(simState.currentStressLevel > 6 ? AppTheme.statusError : moodColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final simState = ref.watch(simulationProvider(widget.scenario.id));

    return Scaffold(
      body: PremiumBackground(
        mood: simState.currentMood,
        stressLevel: simState.currentStressLevel,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(simState),
              if (!simState.hasStarted)
                Expanded(child: _buildDifficultySelectionView())
              else ...[
                _buildPersonaStatusPanel(simState),
                Expanded(
                  child: (simState.isLoading && simState.messages.isEmpty)
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.accentViolet))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: simState.messages.length + (simState.isAITyping ? 1 : 0),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index == simState.messages.length) return _buildTypingIndicator();
                          final msg = simState.messages[index];
                          return _buildMessageBubble(msg['role'] == 'user', msg['content'], index);
                        },
                      ),
                ),
                _buildInputArea(simState),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelectionView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Category Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentViolet.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.scenario.category.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.accentViolet,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ).animate().fadeIn().scale(),
          const SizedBox(height: 16),
          // Scenario Title
          Text(
            widget.scenario.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 24),
          // Context Card
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppTheme.textSecondary),
                    SizedBox(width: 8),
                    Text(
                      'Senaryo Bağlamı',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.scenario.context,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05, end: 0),
          const SizedBox(height: 32),
          const Text(
            'Zorluk Seviyesi Seçin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ).animate().fadeIn(delay: 350.ms),
          const SizedBox(height: 16),
          
          // Difficulty Cards
          _buildDifficultyCard('easy', 'Kolay', 'İşbirlikçi ve yumuşak başlı. Empatiye hızlı cevap verir.', AppTheme.accentGreen),
          const SizedBox(height: 12),
          _buildDifficultyCard('medium', 'Orta', 'Dengeli ve gerçekçi. Gerçek hayattaki gibi makul tepkiler.', AppTheme.accentViolet),
          const SizedBox(height: 12),
          _buildDifficultyCard('hard', 'Zor', 'Son derece inatçı, savunmacı ve ikna etmesi oldukça zor!', AppTheme.accentCoral),
          
          const SizedBox(height: 40),
          // Start Button
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentViolet.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _startSimulation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentViolet,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Simülasyonu Başlat',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.play_arrow_rounded),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms).scale(),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(String key, String title, String desc, Color color) {
    final isSelected = _selectedDifficulty == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedDifficulty = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppTheme.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          children: [
            // Radio Indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected 
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected ? color : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(0.98, 0.98), duration: 200.ms);
  }

  Widget _buildAppBar(SimulationState simState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.textPrimary),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.scenario.title, 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppTheme.accentGreen, shape: BoxShape.circle),
                    ).animate(onPlay: (c) => c.repeat()).fade(duration: 800.ms).then().fade(duration: 800.ms),
                    const SizedBox(width: 6),
                    const Text('Canlı Simülasyon', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _isSoundOn ? AppTheme.accentViolet : AppTheme.textTertiary,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isSoundOn = !_isSoundOn;
              });
              if (!_isSoundOn) {
                _tts.stop();
              } else if (simState.messages.isNotEmpty && simState.messages.last['role'] == 'assistant') {
                _speak(simState.messages.last['content']);
              }
            },
          ),
          (simState.isLoading || _localTransitionLoading)
            ? const SizedBox(width: 48, height: 48, child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentViolet))))
            : TextButton(
                onPressed: _confirmEndSimulation,
                child: const Text('Bitir', style: TextStyle(color: AppTheme.accentViolet, fontWeight: FontWeight.bold)),
              ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(bool isUser, String content, int index) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          gradient: isUser ? LinearGradient(
            colors: [AppTheme.accentViolet, AppTheme.accentViolet.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          color: isUser ? null : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(isUser ? 22 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isUser ? 0.1 : 0.03), 
              blurRadius: 12, 
              offset: const Offset(0, 4)
            )
          ],
          border: isUser ? null : Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUser ? Colors.white : AppTheme.textPrimary, 
            height: 1.5,
            fontSize: 15,
            fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms, curve: Curves.easeOut).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8), 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Persona yazıyor', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            _buildDot(0),
            _buildDot(1),
            _buildDot(2),
          ],
        ),
      ),
    ).animate().fade(duration: 200.ms);
  }

  Widget _buildDot(int index) {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.only(right: 3),
      decoration: const BoxDecoration(color: AppTheme.textTertiary, shape: BoxShape.circle),
    ).animate(onPlay: (c) => c.repeat()).fadeIn(delay: (index * 200).ms, duration: 400.ms).then().fadeOut(duration: 400.ms);
  }

  Widget _buildInputArea(SimulationState simState) {
    final userTurns = simState.messages.where((m) => m['role'] == 'user').length;
    final isLimitReached = userTurns >= 8;

    if (isLimitReached) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentViolet),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Konuşma limitine ulaştınız. Harika bir prova gerçekleştirdiniz! Şimdi AI analizinizi alalım.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, height: 1.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _endSimulation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentViolet,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 2,
                ),
                child: const Text(
                  'Bitir ve Analiz Et',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(delay: 2.seconds, duration: 1.5.seconds),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isLimitReached && simState.sessionId != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _getMentorHint,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        simState.isHintLoading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.accentGold),
                            )
                          : const Icon(Icons.lightbulb_outline_rounded, size: 14, color: AppTheme.accentGold),
                        const SizedBox(width: 6),
                        const Text(
                          'Yapay Zeka Mentorundan İpucu Al',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentGold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          maxLines: 4,
                          minLines: 1,
                          style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Mesajınızı yazın...',
                            hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded, 
                          color: _isListening ? AppTheme.statusError : AppTheme.textTertiary,
                        ).animate(target: _isListening ? 1 : 0).scale(begin: const Offset(1.0, 1.0), end: const Offset(1.2, 1.2)).shake(duration: 500.ms),
                        onPressed: _isListening ? _stopListening : _startListening,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.accentViolet, AppTheme.accentSky],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentViolet.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
