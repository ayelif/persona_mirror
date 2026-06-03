// @ts-nocheck
import { handleCors, corsHeaders } from '../_shared/cors.ts';
import { createAdminClient } from '../_shared/supabaseClient.ts';

Deno.serve(async (req) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  const supabase = createAdminClient();
  const { method } = req;
  const url = new URL(req.url);
  const path = url.pathname.split('/').filter(Boolean);
  
  // path[0] will be 'scenarios' when called via /functions/v1/scenarios
  const isTemplates = path.includes('templates');

  try {
    // GET /scenarios/templates
    if (method === 'GET' && isTemplates) {
      const templates = [
        {
          id: 't1',
          title: 'Zam İste',
          category: 'İş Hayatı',
          context: 'Yöneticinden %30 zam istiyorsun. Şirket hedeflerini tuturdun ama bütçe kısıtlı olabilir.',
        },
        {
          id: 't2',
          title: 'Sınır Koy',
          category: 'Arkadaşlık',
          context: 'Sürekli borç isteyen bir arkadaşına artık veremeyeceğini nazikçe ama kararlı bir şekilde söylüyorsun.',
        },
        {
          id: 't3',
          title: 'İlişkiyi Bitir',
          category: 'Romantik',
          context: 'Uzun süredir devam eden ama artık yürümeyen ilişkini saygı çerçevesinde sonlandırıyorsun.',
        },
        {
          id: 't4',
          title: 'Zorlu Geri Bildirim',
          category: 'İş Hayatı',
          context: 'Performansı düşen bir ekip arkadaşına, kalbini kırmadan ama durumu net bir şekilde açıklayarak geri bildirim veriyorsun.',
        },
        {
          id: 't5',
          title: 'Aileyi İkna Et',
          category: 'Aile',
          context: 'Kendi kararlarını almak istediğini ve hayatına müdahale edilmesinden rahatsız olduğunu ailene açıklıyorsun.',
        },
        {
          id: 't6',
          title: 'Hata Kabul Etme',
          category: 'İş Hayatı',
          context: 'Önemli bir projede yaptığın hatayı yöneticine dürüstçe açıklayıp çözüm önerileri sunuyorsun.',
        },
        {
          id: 't7',
          title: 'Ev Arkadaşıyla Tartışma',
          category: 'Sosyal',
          context: 'Evdeki temizlik ve düzen konusundaki rahatsızlığını ev arkadaşına uygun bir dille anlatıyorsun.',
        },
        {
          id: 't8',
          title: 'Müşteri Kaybı Telafisi',
          category: 'İş Hayatı',
          context: 'Sizden kaynaklı bir hata nedeniyle ayrılmak isteyen büyük bir müşteriyi kalmaya ikna etmeye çalışıyorsun.',
        }
      ];
      return new Response(JSON.stringify(templates), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // GET /scenarios?user_id=...
    if (method === 'GET') {
      const userId = url.searchParams.get('user_id');
      if (!userId) throw new Error('User ID is required');

      const { data, error } = await supabase
        .from('scenarios')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false });

      if (error) throw error;
      return new Response(JSON.stringify(data), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // POST /scenarios
    if (method === 'POST') {
      const body = await req.json();
      const { data, error } = await supabase
        .from('scenarios')
        .insert([body])
        .select()
        .single();

      if (error) throw error;
      return new Response(JSON.stringify(data), {
        status: 201,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    return new Response('Method not allowed', { status: 405 });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

