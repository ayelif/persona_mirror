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
    if (user == null) throw Exception('Oturum açmış kullanıcı bulunamadı.');

    String? effectiveUserId;

    // ADIM 1: Veritabanından e-posta ile ID'yi çekmeyi dene (RLS kapalıysa çalışır)
    try {
      final res = await _client.from('users').select('id').eq('email', user.email!).maybeSingle();
      if (res != null) {
        effectiveUserId = res['id'].toString();
      }
    } catch (_) {}

    // ADIM 2: Eğer hala yoksa, backend fonksiyonunu "getirici" olarak kullan
    if (effectiveUserId == null) {
      try {
        // Backend'e "ben buradayım" de ve güncel ID'yi al
        final syncRes = await _client.functions.invoke('users', body: {
          'email': user.email,
          'id': user.id, // Bunu göndersek de backend eski kodla görmezden gelebilir
        });
        
        if (syncRes.data != null && syncRes.data['id'] != null) {
          effectiveUserId = syncRes.data['id'].toString();
        }
      } catch (e) {
        // Eğer 400 (Duplicate) hatası alıyorsak, bu demektir ki kullanıcı var.
        // Bazı durumlarda hata mesajının içinden ID'yi çekebiliriz ama bu zor.
      }
    }

    // ADIM 3: Son çare: Eğer hala ID bulunamadıysa ve senaryo oluşturma hata veriyorsa, 
    // veritabanındaki "gerçek" ID'ye ulaşmanın başka yolu yoktur. 
    effectiveUserId ??= user.id;
    
    print('Kullanılacak Senaryo UserID: $effectiveUserId');

    final response = await _client.from('scenarios').insert({
      'title': title,
      'context': context,
      'category': category,
      'user_id': effectiveUserId,
    }).select().single();

    return Scenario.fromJson(response);
  }

  // Senaryo sil
  Future<void> deleteScenario(String id) async {
    await _client.from('scenarios').delete().eq('id', id);
  }

  // Kullanıcı istatistiklerini getir
  Future<Map<String, dynamic>> getStats() async {
    final user = _client.auth.currentUser;
    if (user == null) return {'total_sessions': 0, 'avg_score': 0, 'skills': {}};

    try {
      // Toplam seans sayısı
      final sessionsRes = await _client
          .from('sessions')
          .select('id')
          .eq('user_id', user.id);
      
      final totalSessions = (sessionsRes as List).length;

      // Analiz sonuçlarından ortalama skorlar
      // NOT: analyses tablosunda user_id yokmuş, session_id üzerinden join gerekebilir 
      // ama şimdilik RLS'in çalıştığını veya tümünü getirdiğimizi varsayıyoruz.
      final analysesRes = await _client
          .from('analyses')
          .select('empathy_score, clarity_score, assertiveness_score');

      double avgEmpathy = 0;
      double avgClarity = 0;
      double avgAssertiveness = 0;
      int count = 0;

      if (analysesRes != null && (analysesRes as List).isNotEmpty) {
        final list = analysesRes as List;
        count = list.length;
        for (var item in list) {
          avgEmpathy += (item['empathy_score'] ?? 0);
          avgClarity += (item['clarity_score'] ?? 0);
          avgAssertiveness += (item['assertiveness_score'] ?? 0);
        }
        avgEmpathy /= count;
        avgClarity /= count;
        avgAssertiveness /= count;
      }

      final totalAvg = count > 0 ? (avgEmpathy + avgClarity + avgAssertiveness) / 3 * 10 : 0;

      return {
        'total_sessions': totalSessions,
        'avg_score': totalAvg.toInt(),
        'skills': {
          'Empati': avgEmpathy / 10,
          'Netlik': avgClarity / 10,
          'Kararlılık': avgAssertiveness / 10,
        }
      };
    } catch (e) {
      print('İstatistik getirme hatası: $e');
      return {'total_sessions': 0, 'avg_score': 0, 'skills': {}};
    }
  }
}




