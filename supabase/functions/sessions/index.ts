// @ts-nocheck
import { handleCors, corsHeaders } from '../_shared/cors.ts';
import { createAdminClient } from '../_shared/supabaseClient.ts';

const GROQ_API_KEY = Deno.env.get('GROQ_API_KEY') || '';
const GROQ_API_URL = 'https://api.groq.com/openai/v1/chat/completions';

Deno.serve(async (req) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  const supabase = createAdminClient();
  const { method } = req;
  const url = new URL(req.url);
  const path = url.pathname.split('/').filter(Boolean);

  try {
    // POST /sessions (Yeni oturum başlat)
    if (method === 'POST' && path.length === 1) {
      const { scenario_id, user_id } = await req.json();
      
      const { data: scenario } = await supabase
        .from('scenarios')
        .select('*')
        .eq('id', scenario_id)
        .single();

      const { data: session, error: sError } = await supabase
        .from('sessions')
        .insert([{ scenario_id, user_id, status: 'active' }])
        .select()
        .single();

      if (sError) throw sError;

      const systemPrompt = `Sen bir rol yapma simülatörüsün. Şu senaryoda belirtilen karakteri canlandıracaksın: ${scenario.context}. Konuşmaya doğal ve kısa bir şekilde başla.`;
      
      const response = await fetch(GROQ_API_URL, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${GROQ_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'llama-3.3-70b-versatile',
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: 'Merhaba, simülasyonu başlat.' }
          ],
        }),
      });

      const result = await response.json();
      const firstMessage = result.choices[0].message.content;

      await supabase.from('messages').insert([
        { session_id: session.id, role: 'assistant', content: firstMessage }
      ]);

      return new Response(JSON.stringify({ session, firstMessage }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // POST /sessions/:id/message (Mesaj gönder)
    if (method === 'POST' && path.length === 3 && path[2] === 'message') {
      const sessionId = path[1];
      const { content } = await req.json();

      await supabase.from('messages').insert([{ session_id: sessionId, role: 'user', content }]);

      const { data: history } = await supabase
        .from('messages')
        .select('role, content')
        .eq('session_id', sessionId)
        .order('created_at', { ascending: true });

      const { data: sessionData } = await supabase
        .from('sessions')
        .select('scenarios(context)')
        .eq('id', sessionId)
        .single();

      const systemPrompt = `Canlandıracağın karakter bağlamı: ${sessionData.scenarios.context}. Karşı tarafın mesajlarına uygun ve doğal tepkiler ver.`;

      const response = await fetch(GROQ_API_URL, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${GROQ_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'llama-3.3-70b-versatile',
          messages: [
            { role: 'system', content: systemPrompt },
            ...history.map(m => ({ role: m.role, content: m.content }))
          ],
        }),
      });

      const result = await response.json();
      const reply = result.choices[0].message.content;

      const { data: message } = await supabase
        .from('messages')
        .insert([{ session_id: sessionId, role: 'assistant', content: reply }])
        .select()
        .single();

      return new Response(JSON.stringify(message), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // PATCH /sessions/:id/end (Oturumu sonlandır ve analiz tetikle)
    if (method === 'PATCH' && path.length === 3 && path[2] === 'end') {
      const sessionId = path[1];

      // Session status güncelle
      const { error: updateError } = await supabase
        .from('sessions')
        .update({ status: 'completed', ended_at: new Date().toISOString() })
        .eq('id', sessionId);

      if (updateError) throw updateError;

      // Analiz fonksiyonunu tetikle (opsiyonel: arka planda çalışabilir)
      // Burada doğrudan analiz fonksiyonuna POST isteği atıyoruz
      const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
      const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
      
      const analysisUrl = `${supabaseUrl}/functions/v1/analyses?session_id=${sessionId}`;
      
      // Analiz işlemini tetikle ama yanıtı beklemeden devam et (opsiyonel)
      // Ya da bekleyip sonucu dön. Plan "iç çağrı" diyor.
      const analysisResponse = await fetch(analysisUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${serviceRoleKey}`,
          'Content-Type': 'application/json',
        },
      });

      if (!analysisResponse.ok) {
        console.error('Analiz tetiklenirken hata oluştu:', await analysisResponse.text());
      }

      return new Response(JSON.stringify({ message: 'Session ended and analysis triggered' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    return new Response('Path not found', { status: 404 });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
