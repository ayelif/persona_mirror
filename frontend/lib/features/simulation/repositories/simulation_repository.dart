import 'package:supabase_flutter/supabase_flutter.dart';

class SimulationRepository {
  final SupabaseClient _client;

  SimulationRepository(this._client);

  // Simülasyon oturumu başlat
  Future<Map<String, dynamic>> startSimulation({
    required String scenarioId,
    required String difficulty,
  }) async {
    final user = _client.auth.currentUser;
    final response = await _client.functions.invoke('sessions', body: {
      'scenario_id': scenarioId,
      'user_id': user?.id,
      'difficulty': difficulty,
    });

    if (response.status != 200) {
      throw Exception('Simülasyon başlatılamadı: ${response.status}');
    }

    return response.data as Map<String, dynamic>;
  }

  // Karaktere mesaj gönder
  Future<Map<String, dynamic>> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    final response = await _client.functions.invoke(
      'sessions/$sessionId/message',
      body: {'content': content},
    );

    if (response.status != 200) {
      throw Exception('Mesaj gönderilemedi: ${response.status}');
    }

    return response.data as Map<String, dynamic>;
  }

  // Oturumu sonlandır
  Future<void> endSimulation({required String sessionId}) async {
    final response = await _client.functions.invoke('sessions', body: {
      'session_id': sessionId,
      'action': 'end',
    });

    if (response.status != 200) {
      throw Exception('Simülasyon sonlandırılamadı: ${response.status}');
    }
  }

  // Mentor ipucu getir
  Future<Map<String, String>> getMentorHint({required String sessionId}) async {
    final response = await _client.functions.invoke(
      'sessions/$sessionId/hint',
      method: HttpMethod.post,
    );

    if (response.status != 200) {
      throw Exception('İpucu alınamadı: ${response.status}');
    }

    final data = response.data as Map;
    return {
      'tip': (data['tip'] ?? '').toString(),
      'suggested_reply': (data['suggested_reply'] ?? '').toString(),
    };
  }
}
