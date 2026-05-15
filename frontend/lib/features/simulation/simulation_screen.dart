import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:persona_mirror/core/theme/app_theme.dart';
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
            backgroundColor: Colors.redAccent,
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
          curve: Curves.easeOutBack,
        );
      }
    });
  }

  Future<void> _confirmEndSimulation() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simülasyonu Bitir?'),
        content: const Text('Bu oturumu sonlandırmak ve analiz almak istiyor musunuz?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Devam Et')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Bitir ve Analiz Et'),
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
      await _supabase.functions.invoke('sessions/$_sessionId/end', method: HttpMethod.patch);
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(widget.scenario.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ).animate(onPlay: (c) => c.repeat()).fade(duration: 800.ms).then().fade(duration: 800.ms),
                const SizedBox(width: 6),
                const Text('Canlı Simülasyon', style: TextStyle(fontSize: 12, color: AppTheme.mutedTextColor)),
              ],
            ),
          ],
        ),
        actions: [
          _isLoading 
            ? const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))))
            : Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: _confirmEndSimulation,
                  child: const Text('Bitir', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                ),
              ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: _isLoading && _messages.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: _messages.length + (_isAITyping ? 1 : 0),
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
          color: isUser ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(isUser ? 22 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isUser ? 0.1 : 0.03), 
              blurRadius: 12, 
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUser ? Colors.white : AppTheme.textColor, 
            height: 1.5,
            fontSize: 15,
            fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms, curve: Curves.easeOut).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Persona yazıyor', style: TextStyle(fontSize: 13, color: AppTheme.mutedTextColor)),
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
      decoration: const BoxDecoration(color: AppTheme.mutedTextColor, shape: BoxShape.circle),
    ).animate(onPlay: (c) => c.repeat()).fadeIn(delay: (index * 200).ms, duration: 400.ms).then().fadeOut(duration: 400.ms);
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F9),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: 4,
                      minLines: 1,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Mesajınızı buraya yazın...',
                        hintStyle: TextStyle(color: AppTheme.mutedTextColor, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic_none_rounded, color: AppTheme.mutedTextColor),
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
              height: 48,
              width: 48,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.primaryColor, blurRadius: 8, offset: Offset(0, 3), spreadRadius: -2)]
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}


