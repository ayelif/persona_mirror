import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/spacing.dart';


class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Merhaba Elif, bugün seninle maaş artışı konusunu pratik edeceğiz. Ben patronun Ahmet Bey rolündeyim. Hazırsan başlayabiliriz.',
      'isAi': true
    },
  ];
  
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  void _handleSendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({
        'text': _messageController.text,
        'isAi': false,
      });
      _messageController.clear();
      _isTyping = true;
    });
    
    _scrollToBottom();
    
    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'text': 'Anlıyorum. Peki, son dönemdeki performansını nasıl değerlendiriyorsun? Şirkete kattığın en büyük değer nedir sence?',
            'isAi': true,
          });
        });
        _scrollToBottom();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildChatList(),
          ),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.bgPrimary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.accentViolet.withValues(alpha: 0.1),
            child: const Icon(Icons.person_rounded, color: AppTheme.accentViolet),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ahmet Bey',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Patron Modu',
                style: TextStyle(color: AppTheme.accentViolet, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            onPressed: () => context.push('/analysis'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentCoral.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Analiz Al',
                style: TextStyle(color: AppTheme.accentCoral, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.screenPaddingH,
        vertical: AppLayout.screenPaddingV,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _buildMessageBubble(msg['text'], msg['isAi']);
      },
    );
  }

  Widget _buildMessageBubble(String text, bool isAi) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAi ? AppTheme.bgCard : AppTheme.accentViolet,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isAi ? AppTheme.shadowSm : [
                  BoxShadow(
                    color: AppTheme.accentViolet.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isAi ? AppTheme.textPrimary : AppTheme.textInverse,
                  fontSize: 15,
                  height: 1.4,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isAi ? '14:20' : '14:21',
              style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: List.generate(3, (index) => 
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: AppTheme.accentViolet,
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (c) => c.repeat()).scale(
                  delay: (index * 200).ms,
                  duration: 600.ms,
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                ).fadeOut(curve: Curves.easeInOut)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _handleSendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Cevabınızı buraya yazın...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14, color: AppTheme.textTertiary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleSendMessage,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accentViolet, AppTheme.accentPurple],
                ),
                shape: BoxShape.circle,
                boxShadow: AppTheme.glowViolet,
              ),
              child: const Icon(Icons.arrow_upward_rounded, color: AppTheme.textInverse),
            ),
          ),
        ],
      ),
    );
  }
}
