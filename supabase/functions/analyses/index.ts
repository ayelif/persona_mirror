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

  try {
    if (method === 'POST') {
      const sessionId = url.searchParams.get('session_id');
      if (!sessionId) throw new Error('session_id is required');

      // Önce mevcut analizi kontrol et (çakışmayı önlemek için)
      const { data: existingAnalysis } = await supabase
        .from('analyses')
        .select('*')
        .eq('session_id', sessionId)
        .maybeSingle();
      
      if (existingAnalysis) {
        return new Response(JSON.stringify(existingAnalysis), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }

      const { data: messages } = await supabase
        .from('messages')
        .select('role, content')
        .eq('session_id', sessionId)
        .order('created_at', { ascending: true });

      const conversationText = messages.map(m => `${m.role}: ${m.content}`).join('\n');

      const prompt = `Aşağıdaki konuşma simülasyonunu analiz et. Kullanıcının (user) performansını Empati, Netlik ve Kararlılık açısından 1-10 arası puanla. Sadece aşağıdaki JSON formatında yanıt ver (ekstra açıklama yazma):
      {
        "empathy_score": number,
        "clarity_score": number,
        "assertiveness_score": number,
        "summary": "kısa özet",
        "strengths": ["güçlü yan 1"],
        "improvements": ["gelişim alanı 1"],
        "alternative_lines": ["şu şekilde de diyebilirdin"]
      }

      Konuşma:
      ${conversationText}`;

      const response = await fetch(GROQ_API_URL, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${GROQ_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'llama-3.3-70b-versatile',
          messages: [{ role: 'user', content: prompt }],
          response_format: { type: "json_object" }
        }),
      });

      const result = await response.json();
      const analysisData = JSON.parse(result.choices[0].message.content);

      const { data, error } = await supabase
        .from('analyses')
        .insert([{ ...analysisData, session_id: sessionId }])
        .select()
        .single();

      if (error) throw error;
      
      await supabase.from('sessions').update({ status: 'completed', ended_at: new Date().toISOString() }).eq('id', sessionId);

      return new Response(JSON.stringify(data), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (method === 'GET') {
      const sessionId = url.searchParams.get('session_id');
      if (!sessionId) throw new Error('session_id is required');

      const { data, error } = await supabase
        .from('analyses')
        .select('*')
        .eq('session_id', sessionId)
        .maybeSingle();

      if (error) throw error;
      if (!data) return new Response(JSON.stringify({ error: 'Analysis not found' }), { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });

      return new Response(JSON.stringify(data), {
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
