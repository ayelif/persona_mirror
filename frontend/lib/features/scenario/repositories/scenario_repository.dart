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
        title: 'Zam İste',
        category: 'İş Hayatı',
        context: 'Yöneticinden %30 zam istiyorsun. Şirket hedeflerini tuturdun ama bütçe kısıtlı olabilir.',
        createdAt: DateTime.now(),
      ),
      Scenario(
        id: 't2',
        title: 'Sınır Koy',
        category: 'Arkadaşlık',
        context: 'Sürekli borç isteyen bir arkadaşına artık veremeyeceğini nazikçe ama kararlı bir şekilde söylüyorsun.',
        createdAt: DateTime.now(),
      ),
      Scenario(
        id: 't3',
        title: 'İlişkiyi Bitir',
        category: 'Romantik',
        context: 'Uzun süredir devam eden ama artık yürümeyen ilişkini saygı çerçevesinde sonlandırıyorsun.',
        createdAt: DateTime.now(),
      ),
      Scenario(
        id: 't4',
        title: 'Zorlu Geri Bildirim',
        category: 'İş Hayatı',
        context: 'Performansı düşen bir ekip arkadaşına geri bildirim veriyorsun.',
        createdAt: DateTime.now(),
      ),
      Scenario(
        id: 't5',
        title: 'Aileyi İkna Et',
        category: 'Aile',
        context: 'Kendi kararlarını ailene açıklıyorsun.',
        createdAt: DateTime.now(),
      ),
      Scenario(
        id: 't6',
        title: 'Hata Kabul Etme',
        category: 'İş Hayatı',
        context: 'Yaptığın bir hatayı dürüstçe açıklayıp çözüm sunuyorsun.',
        createdAt: DateTime.now(),
      ),
      Scenario(
        id: 't7',
        title: 'Ev Arkadaşıyla Tartışma',
        category: 'Sosyal',
        context: 'Evdeki düzen konusundaki rahatsızlığını ev arkadaşına anlatıyorsun.',
        createdAt: DateTime.now(),
      ),
      Scenario(
        id: 't8',
        title: 'Müşteri Kaybı Telafisi',
        category: 'İş Hayatı',
        context: 'Ayrılmak isteyen müşteriyi kalmaya ikna etmeye çalışıyorsun.',
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
      // Toplam seans sayısı (Sadece tamamlanmış provalar)
      final sessionsRes = await _client
          .from('sessions')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'completed');
      
      final totalSessions = (sessionsRes as List).length;

      // Analiz sonuçlarından ortalama skorlar ve rozet kriterleri
      final analysesRes = await _client
          .from('analyses')
          .select('empathy_score, clarity_score, assertiveness_score');

      double avgEmpathy = 0;
      double avgClarity = 0;
      double avgAssertiveness = 0;
      
      double maxEmpathy = 0;
      double maxClarity = 0;
      double maxAssertiveness = 0;
      bool hasNetVeKararli = false;
      int count = 0;

      if (analysesRes != null && (analysesRes as List).isNotEmpty) {
        final list = analysesRes as List;
        count = list.length;
        for (var item in list) {
          final emp = (item['empathy_score'] ?? 0).toDouble();
          final clr = (item['clarity_score'] ?? 0).toDouble();
          final asr = (item['assertiveness_score'] ?? 0).toDouble();

          avgEmpathy += emp;
          avgClarity += clr;
          avgAssertiveness += asr;

          if (emp > maxEmpathy) maxEmpathy = emp;
          if (clr > maxClarity) maxClarity = clr;
          if (asr > maxAssertiveness) maxAssertiveness = asr;

          if (clr >= 8 && asr >= 8) {
            hasNetVeKararli = true;
          }
        }
        avgEmpathy /= count;
        avgClarity /= count;
        avgAssertiveness /= count;
      }

      final totalAvg = count > 0 ? (avgEmpathy + avgClarity + avgAssertiveness) / 3 * 10 : 0;

      // Dinamik rozet durumları ve ilerleme hesaplaması
      final achievements = [
        {
          'id': 'first_step',
          'title': 'İlk Adım',
          'description': 'Persona Mirror dünyasına ilk adımını atarak ilk provanı başarıyla tamamladın.',
          'isUnlocked': totalSessions >= 1,
          'progress': totalSessions >= 1 ? 1.0 : 0.0,
          'iconName': 'first_step',
          'colorName': 'violet',
        },
        {
          'id': 'empathy_master',
          'title': 'Empati Ustası',
          'description': 'Karşı tarafın duygularını anlama ve onaylama konusunda üstün başarı gösterdin (Skor >= 8).',
          'isUnlocked': maxEmpathy >= 8,
          'progress': (maxEmpathy / 8.0).clamp(0.0, 1.0),
          'iconName': 'empathy',
          'colorName': 'coral',
        },
        {
          'id': 'clear_assertive',
          'title': 'Net ve Kararlı',
          'description': 'Fikirlerini net, dolaysız ve kendinden emin bir şekilde ifade ettin (Netlik & Kararlılık >= 8).',
          'isUnlocked': hasNetVeKararli,
          'progress': (((maxClarity / 8.0).clamp(0.0, 1.0) + (maxAssertiveness / 8.0).clamp(0.0, 1.0)) / 2.0).clamp(0.0, 1.0),
          'iconName': 'assertive',
          'colorName': 'sky',
        },
        {
          'id': 'negotiation_genius',
          'title': 'Müzakere Dehası',
          'description': 'Zorlu durumlarda mükemmel bir denge kurarak genel ortalama skorunu 80+ yaptın.',
          'isUnlocked': totalSessions >= 1 && totalAvg >= 80,
          'progress': (totalAvg / 80.0).clamp(0.0, 1.0),
          'iconName': 'genius',
          'colorName': 'gold',
        },
        {
          'id': 'consistent_comm',
          'title': 'İstikrarlı İletişimci',
          'description': 'Gelişim yolculuğuna sadık kalarak en az 3 adet provayı başarıyla tamamladın.',
          'isUnlocked': totalSessions >= 3,
          'progress': (totalSessions / 3.0).clamp(0.0, 1.0),
          'iconName': 'consistent',
          'colorName': 'teal',
        },
      ];

      return {
        'total_sessions': totalSessions,
        'avg_score': totalAvg.toInt(),
        'skills': {
          'Empati': avgEmpathy / 10,
          'Netlik': avgClarity / 10,
          'Kararlılık': avgAssertiveness / 10,
        },
        'achievements': achievements,
      };
    } catch (e) {
      print('İstatistik getirme hatası: $e');
      return {
        'total_sessions': 0,
        'avg_score': 0,
        'skills': {},
        'achievements': [],
      };
    }
  }
}




