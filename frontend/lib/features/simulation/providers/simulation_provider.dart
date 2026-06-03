import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persona_mirror/features/simulation/repositories/simulation_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SimulationState {
  final List<Map<String, dynamic>> messages;
  final bool isLoading;
  final bool isAITyping;
  final String? sessionId;
  final String currentMood;
  final int currentStressLevel;
  final bool isHintLoading;
  final Map<String, String>? currentHint;
  final String selectedDifficulty;
  final bool hasStarted;

  SimulationState({
    required this.messages,
    required this.isLoading,
    required this.isAITyping,
    this.sessionId,
    required this.currentMood,
    required this.currentStressLevel,
    required this.isHintLoading,
    this.currentHint,
    required this.selectedDifficulty,
    required this.hasStarted,
  });

  SimulationState copyWith({
    List<Map<String, dynamic>>? messages,
    bool? isLoading,
    bool? isAITyping,
    String? sessionId,
    String? currentMood,
    int? currentStressLevel,
    bool? isHintLoading,
    Map<String, String>? currentHint,
    String? selectedDifficulty,
    bool? hasStarted,
  }) {
    return SimulationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isAITyping: isAITyping ?? this.isAITyping,
      sessionId: sessionId ?? this.sessionId,
      currentMood: currentMood ?? this.currentMood,
      currentStressLevel: currentStressLevel ?? this.currentStressLevel,
      isHintLoading: isHintLoading ?? this.isHintLoading,
      currentHint: currentHint ?? this.currentHint,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      hasStarted: hasStarted ?? this.hasStarted,
    );
  }

  factory SimulationState.initial() {
    return SimulationState(
      messages: [],
      isLoading: false,
      isAITyping: false,
      currentMood: 'neutral',
      currentStressLevel: 3,
      isHintLoading: false,
      selectedDifficulty: 'medium',
      hasStarted: false,
    );
  }
}

// Repository Provider
final simulationRepositoryProvider = Provider<SimulationRepository>((ref) {
  return SimulationRepository(Supabase.instance.client);
});

// Modern Riverpod 3.0 Notifier extending standard Notifier
class SimulationNotifier extends Notifier<SimulationState> {
  final String scenarioId;

  SimulationNotifier(this.scenarioId);

  late final SimulationRepository _repository;

  @override
  SimulationState build() {
    _repository = ref.watch(simulationRepositoryProvider);
    return SimulationState.initial();
  }

  void setDifficulty(String difficulty) {
    state = state.copyWith(selectedDifficulty: difficulty);
  }

  // Simülasyonu başlatır ve karakterin ilk mesajını alır
  Future<void> startSimulation(String scenarioId) async {
    state = state.copyWith(isLoading: true, hasStarted: true);
    try {
      final data = await _repository.startSimulation(
        scenarioId: scenarioId,
        difficulty: state.selectedDifficulty,
      );

      final session = data['session'];
      final sessionId = session != null ? session['id'] : null;
      
      final String firstMsg = data['firstMessage'] ?? 'Merhaba, hazırsan başlayalım.';
      String mood = 'neutral';
      int stressLevel = 3;

      final msgData = data['message'];
      if (msgData != null) {
        mood = msgData['mood'] ?? 'neutral';
        stressLevel = msgData['stress_level'] ?? 3;
      }

      state = state.copyWith(
        isLoading: false,
        sessionId: sessionId,
        currentMood: mood,
        currentStressLevel: stressLevel,
        messages: [
          {'role': 'assistant', 'content': firstMsg}
        ],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasStarted: false);
      rethrow;
    }
  }

  // İletişim simülasyonuna yeni mesaj gönderir
  Future<String> sendMessage(String content) async {
    final sessionId = state.sessionId;
    if (sessionId == null || state.isAITyping) throw Exception('Geçersiz oturum.');

    final updatedMessages = List<Map<String, dynamic>>.from(state.messages)
      ..add({'role': 'user', 'content': content});

    state = state.copyWith(
      messages: updatedMessages,
      isAITyping: true,
    );

    try {
      final data = await _repository.sendMessage(
        sessionId: sessionId,
        content: content,
      );

      final replyContent = data['content'] ?? '';
      final mood = data['mood'] ?? 'neutral';
      final stressLevel = data['stress_level'] ?? 3;

      final finalMessages = List<Map<String, dynamic>>.from(state.messages)
        ..add({'role': 'assistant', 'content': replyContent});

      state = state.copyWith(
        messages: finalMessages,
        isAITyping: false,
        currentMood: mood,
        currentStressLevel: stressLevel,
      );

      return replyContent;
    } catch (e) {
      state = state.copyWith(isAITyping: false);
      rethrow;
    }
  }

  // Mentor ipucu talep eder
  Future<void> getMentorHint() async {
    final sessionId = state.sessionId;
    if (sessionId == null || state.isHintLoading) return;

    state = state.copyWith(isHintLoading: true);
    try {
      final hint = await _repository.getMentorHint(sessionId: sessionId);
      state = state.copyWith(
        isHintLoading: false,
        currentHint: hint,
      );
    } catch (e) {
      state = state.copyWith(isHintLoading: false);
      rethrow;
    }
  }

  // Simülasyonu sonlandırıp durum güncellemesi tetikler
  Future<void> endSimulation() async {
    final sessionId = state.sessionId;
    if (sessionId == null || state.isLoading) return;

    state = state.copyWith(isLoading: true);
    try {
      await _repository.endSimulation(sessionId: sessionId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // Oturumu sıfırlar
  void reset() {
    state = SimulationState.initial();
  }
}

// Riverpod 3.0 standard family notifier registration with simplified constructor tearing
final simulationProvider = NotifierProvider.autoDispose.family<SimulationNotifier, SimulationState, String>(
  (arg) => SimulationNotifier(arg),
);
