import 'package:flutter/material.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.redAccent));
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cevap alınamadı.')));
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
        context.go('/analysis', extra: _sessionId);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.scenario.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('Canlı Simülasyon', style: TextStyle(fontSize: 12, color: AppTheme.mutedTextColor)),
          ],
        ),
        actions: [
          _isLoading 
            ? const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))))
            : TextButton(
                onPressed: _endSimulation,
                child: const Text('Bitir', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              ),
        ],
      ),


      body: Column(
        children: [
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length + (_isAITyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) return _buildTypingIndicator();
                    final msg = _messages[index];
                    return _buildMessageBubble(msg['role'] == 'user', msg['content']);
                  },
                ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(bool isUser, String content) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Text(
          content,
          style: TextStyle(color: isUser ? Colors.white : AppTheme.textColor, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Text('AI yazıyor...', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.mutedTextColor)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Mesajınızı yazın...',
                filled: true,
                fillColor: const Color(0xFFF3F4F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
