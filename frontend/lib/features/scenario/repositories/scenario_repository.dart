import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:persona_mirror/core/models/scenario.dart';

class ScenarioRepository {
  final SupabaseClient _client;

  ScenarioRepository(this._client);

  // Kullanıcının senaryolarını getir
  Future<List<Scenario>> getScenarios() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('scenarios')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Scenario.fromJson(e)).toList();
  }

  // Hazır şablonları getir (Edge Function'dan)
  Future<List<Scenario>> getTemplates() async {
    try {
      final response = await _client.functions.invoke('scenarios/templates', method: HttpMethod.get);
      
      if (response.status != 200) {
        throw Exception('Şablonlar yüklenemedi: ${response.status}');
      }

      final List data = response.data;
      if (data.isEmpty) return _getDefaultTemplates();
      
      return data.map((e) => Scenario(
        id: e['id'],
        title: e['title'],
        context: e['context'],
        category: e['category'],
        createdAt: DateTime.now(),
      )).toList();
    } catch (e) {
      print('Şablon getirme hatası: $e');
      return _getDefaultTemplates();
    }
  }

  List<Scenario> _getDefaultTemplates() {
    return [
      Scenario(
        id: 't1',
        title: 'Maaş Zammı',
        category: 'İş Hayatı',
        context: 'Yöneticinden zam istiyorsun.',
        createdAt: DateTime.now(),
      ),
      Scenario(
        id: 't2',
        title: 'Sınır Koyma',
        category: 'Arkadaşlık',
        context: 'Bir arkadaşına hayır demen gerekiyor.',
        createdAt: DateTime.now(),
      ),
      Scenario(
        id: 't3',
        title: 'Ayrılık',
        category: 'Romantik',
        context: 'İlişkiyi bitirme konuşması.',
        createdAt: DateTime.now(),
      ),
    ];
  }


  // Yeni senaryo oluştur
  Future<Scenario> createScenario({
    required String title,
    required String context,
    required String category,
  }) async {
    final user = _client.auth.currentUser;
    
    final response = await _client.from('scenarios').insert({
      'title': title,
      'context': context,
      'category': category,
      'user_id': user?.id,
    }).select().single();

    return Scenario.fromJson(response);
  }
}
