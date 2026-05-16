import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/widgets/premium_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:persona_mirror/core/models/scenario.dart';
import 'package:go_router/go_router.dart';

class SimulationScreen extends StatefulWidget {
  final Scenario scenario;
  const SimulationScreen({super.key, required this.scenario});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isAITyping = false;
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  Future<void> _startSimulation() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.functions.invoke('sessions', body: {
        'scenario_id': widget.scenario.id,
        'user_id': _supabase.auth.currentUser?.id,
      });

      if (response.data != null) {
        setState(() {
          _sessionId = response.data['session']['id'];
          _messages.add({
            'role': 'assistant',
            'content': response.data['firstMessage'] ?? 'Merhaba, hazırsan başlayalım.'
          });
        });
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sessionId == null || _isAITyping) return;

    _messageController.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isAITyping = true;
    });
    _scrollToBottom();

    try {
      final response = await _supabase.functions.invoke('sessions/$_sessionId/message', body: {
        'content': text,
      });

      if (response.data != null && mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': response.data['content']
          });
          _isAITyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAITyping = false);
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
    if (_sessionId == null || _isLoading) return;
    
    setState(() => _isLoading = true);
    try {
      // Seansı bitir - Web uyumlu yöntem (Body kullanarak)
      await _supabase.functions.invoke('sessions', body: {
        'session_id': _sessionId,
        'action': 'end',
      });
      if (mounted) {
        context.go('/analysis', extra: _sessionId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Analiz hazırlanırken hata: $e')));
        context.go('/analysis', extra: _sessionId);
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
              Expanded(
                child: _isLoading && _messages.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accentViolet))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: _messages.length + (_isAITyping ? 1 : 0),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) return _buildTypingIndicator();
                        final msg = _messages[index];
                        return _buildMessageBubble(msg['role'] == 'user', msg['content'], index);
                      },
                    ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
          _isLoading 
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

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                    icon: const Icon(Icons.mic_none_rounded, color: AppTheme.textTertiary),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sesli yanıt özelliği yakında eklenecek!'), behavior: SnackBarBehavior.floating),
                      );
                    },
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
    );
  }
}


