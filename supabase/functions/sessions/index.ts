// @ts-nocheck
import { handleCors, corsHeaders } from '../_shared/cors.ts';
import { createAdminClient } from '../_shared/supabaseClient.ts';

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY') || '';
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
    // POST /sessions (Yeni oturum başlat veya sonlandır)
    if (method === 'POST' && path.length === 1) {
      const body = await req.json();
      
      // EĞER SONLANDIRMA AKIŞIYSA (Web uyumluluk için)
      if (body.action === 'end') {
        const sessionId = body.session_id;

        // Session status güncelle
        const { error: updateError } = await supabase
          .from('sessions')
          .update({ status: 'completed', ended_at: new Date().toISOString() })
          .eq('id', sessionId);

        if (updateError) throw updateError;

        // Analiz fonksiyonunu tetikle
        const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
        const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
        
        const analysisUrl = `${supabaseUrl}/functions/v1/analyses?session_id=${sessionId}`;
        
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

      // Yeni oturum başlatma akışı
      const { scenario_id, user_id, difficulty = 'medium' } = body;
      
      const { data: scenario } = await supabase
        .from('scenarios')
        .select('*')
        .eq('id', scenario_id)
        .single();

      const { data: session, error: sError } = await supabase
        .from('sessions')
        .insert([{ scenario_id, user_id, status: `active_${difficulty}` }])
        .select()
        .single();

      if (sError) throw sError;

      let difficultyPrompt = "";
      if (difficulty === 'easy') {
        difficultyPrompt = "Bu senaryoda KOLAY (Anlayışlı ve İşbirlikçi) zorluk seviyesindesin. Kullanıcıya karşı daha yumuşak, uzlaşmacı ve empatiye hızlı cevap veren bir tutum sergile. İkna edilmeye yatkın ol.";
      } else if (difficulty === 'hard') {
        difficultyPrompt = "Bu senaryoda ZOR (İnatçı ve Defansif) zorluk seviyesindesin. Hemen ikna olma! Karşı argümanlar sun, kendi çıkarlarunu savun, hafif manipülatif veya mesafeli bir ton kullan. Kullanıcının empati sınırlarını ve kararlılığını sonuna kadar test et.";
      } else {
        difficultyPrompt = "Bu senaryoda ORTA (Gerçekçi ve Dengeli) zorluk seviyesindesin. Gerçek hayattaki gibi makul ölçüde savunmacı ama yapıcı tekliflere açık bir insan gibi davran.";
      }

      const systemPrompt = `Sen kesinlikle bir yapay zeka değilsin! Sen şu senaryodaki gerçek bir insansın ve doğrudan o karakteri canlandırıyorsun:
Karakter Bağlamı ve Rolün: ${scenario.context}

${difficultyPrompt}

ROL YAPMA VE İLETİŞİM KURALLARI (KRİTİK):
1. ASLA yapay zeka olduğunu belli etme. Cümlelerin kitap veya ders kitabı gibi kusursuz, soğuk ve mesafeli bir Türkçe ile OLMASIN.
2. Günlük konuşma dilini (colloquial) kullan. Gerçek insanların konuştuğu gibi; ünlemler, duraklamalar ("ya", "yani", "şey", "falan", "ne bileyim", "off", "aman"), duygusal tepkiler ve doğal konuşma akışı içersin.
3. Karakterin cinsiyeti, yaşı ve sosyal durumuna tamamen bürün. Eğer bir kadın rolündeysen veya sitemkar/kırgın bir durumdaysan, bu duyguları samimi ve gerçekçi bir insan tepkisiyle yansıt. Asla yapay, mekanik ya da müşteri temsilcisi gibi kibar davranma!
4. Cevapların kısa, vurucu ve tamamen bir mesajlaşma/doğal diyalog gibi olsun (Tek seferde en fazla 2, nadiren 3 kısa cümle). Uzun paragraflar yazma.
5. Doğrudan birinci tekil şahıs ("Ben") olarak konuş. Asla diyalog dışı notlar veya meta-açıklamalar yazma.
6. Konuşmaya karakterinin bağlamına uygun şekilde doğal bir ilk cümleyle başla.

Yalnızca aşağıdaki JSON yapısıyla yanıt ver:
{
  "reply": "Doğrudan karakterin ağzından çıkacak ilk konuşma cümlesi...",
  "mood": "neutral" | "satisfied" | "defensive" | "frustrated" | "agitated",
  "stress_level": 1-10 arası sayı
}

Lütfen bu JSON formatının dışına çıkma ve ekstra açıklama yapma.`;
      
      let aiResponse;

      if (GEMINI_API_KEY) {
        try {
          console.log("Gemini API ile ilk mesaj başlatılıyor...");
          const GEMINI_API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`;
          const response = await fetch(GEMINI_API_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              contents: [{ role: 'user', parts: [{ text: 'Merhaba, simülasyonu başlat.' }] }],
              systemInstruction: { parts: [{ text: systemPrompt }] },
              generationConfig: { responseMimeType: "application/json" }
            })
          });

          if (!response.ok) {
            throw new Error(`Gemini API returned status ${response.status}: ${await response.text()}`);
          }

          const result = await response.json();
          const text = result.candidates[0].content.parts[0].text;
          aiResponse = JSON.parse(text);
          console.log("Gemini ilk mesaj başarıyla alındı!");
        } catch (geminiError) {
          console.error("Gemini API hatası (İlk mesaj), Groq modeline geçiliyor:", geminiError);
        }
      }

      if (!aiResponse) {
        console.log("Groq API ile ilk mesaj başlatılıyor...");
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
            response_format: { type: "json_object" }
          }),
        });

        if (!response.ok) {
          throw new Error(`Groq API returned status ${response.status}: ${await response.text()}`);
        }

        const result = await response.json();
        aiResponse = JSON.parse(result.choices[0].message.content);
      }
      const firstMessage = aiResponse.reply;
      const mood = aiResponse.mood || 'neutral';
      const stressLevel = aiResponse.stress_level || 3;

      const { data: insertedMsg } = await supabase.from('messages').insert([
        { session_id: session.id, role: 'assistant', content: firstMessage }
      ]).select().single();

      return new Response(JSON.stringify({ 
        session, 
        firstMessage,
        message: {
          ...insertedMsg,
          mood,
          stress_level: stressLevel
        }
      }), {
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
        .select('status, scenarios(context)')
        .eq('id', sessionId)
        .single();

      const status = sessionData.status || 'active_medium';
      const difficulty = status.startsWith('active_') ? status.split('_')[1] : 'medium';

      let difficultyPrompt = "";
      if (difficulty === 'easy') {
        difficultyPrompt = "KOLAY Zorluk: Karşı taraf daha yumuşak, uzlaşmacı ve empatiye hızlı cevap veren bir tutumda. İkna edilmeye yatkın ol.";
      } else if (difficulty === 'hard') {
        difficultyPrompt = "ZOR Zorluk: Karşı taraf çok inatçı ve defansif. Hemen ikna olma! Karşı argümanlar sun, kendi çıkarlarını savun, hafif manipülatif veya mesafeli bir ton kullan. Kullanıcının sınırlarını test et.";
      } else {
        difficultyPrompt = "ORTA Zorluk: Gerçek hayattaki gibi makul ölçüde savunmacı ama yapıcı tekliflere açık bir insan.";
      }

      const systemPrompt = `Sen kesinlikle bir yapay zeka değilsin! Sen şu senaryodaki gerçek bir insansın ve doğrudan o karakteri canlandırıyorsun:
Karakter Bağlamı ve Rolün: ${sessionData.scenarios.context}

${difficultyPrompt}

ROL YAPMA VE İLETİŞİM KURALLARI (KRİTİK):
1. ASLA yapay zeka olduğunu belli etme. Cümlelerin kitap veya ders kitabı gibi kusursuz, soğuk ve mesafeli bir Türkçe ile OLMASIN.
2. Günlük konuşma dilini (colloquial) kullan. Gerçek insanların konuştuğu gibi; ünlemler, duraklamalar ("ya", "yani", "şey", "falan", "ne bileyim", "off", "aman"), duygusal tepkiler ve doğal konuşma akışı içersin.
3. Karakterin cinsiyeti, yaşı ve sosyal durumuna tamamen bürün. Eğer bir kadın rolündeysen veya sitemkar/kırgın bir durumdaysan, bu duyguları samimi ve gerçekçi bir insan tepkisiyle yansıt. Asla yapay, mekanik ya da müşteri temsilcisi gibi kibar davranma!
4. Cevapların kısa, vurucu ve tamamen bir mesajlaşma/doğal diyalog gibi olsun (Tek seferde en fazla 2, nadiren 3 kısa cümle). Uzun paragraflar yazma.
5. Doğrudan birinci tekil şahıs ("Ben") olarak konuş. Asla diyalog dışı notlar veya meta-açıklamalar yazma.

Yalnızca aşağıdaki JSON yapısıyla yanıt ver:
{
  "reply": "Doğrudan karakterin ağzından çıkacak yanıt cümlesi...",
  "mood": "neutral" | "satisfied" | "defensive" | "frustrated" | "agitated",
  "stress_level": 1-10 arası sayı
}

Duygu Durumu Kuralları:
- neutral: Normal, sakin, dengeli konuşma.
- satisfied: Kullanıcı empati yaptığında, yapıcı teklifler sunduğunda veya anlayışlı yaklaştığında.
- defensive: Kullanıcı sert veya suçlayıcı konuştuğunda kendini koruma/savunma eğilimi.
- frustrated: Kullanıcı inatçılık yaptığında veya empati kuramadığında yaşanacak hayal kırıklığı.
- agitated: Kullanıcı haddini aştığında, saygısızlık yaptığında veya aşırı baskı uyguladığında yaşanacak öfke/gerilim.

Lütfen bu JSON formatının dışına çıkma ve ekstra açıklama yapma.`;

      let aiResponse;

      if (GEMINI_API_KEY) {
        try {
          console.log("Gemini API ile sohbet yanıtı oluşturuluyor...");
          const GEMINI_API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`;
          
          const geminiContents = history.map(m => ({
            role: m.role === 'assistant' ? 'model' : 'user',
            parts: [{ text: m.content }]
          }));

          const response = await fetch(GEMINI_API_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              contents: geminiContents,
              systemInstruction: { parts: [{ text: systemPrompt }] },
              generationConfig: { responseMimeType: "application/json" }
            })
          });

          if (!response.ok) {
            throw new Error(`Gemini API returned status ${response.status}: ${await response.text()}`);
          }

          const result = await response.json();
          const text = result.candidates[0].content.parts[0].text;
          aiResponse = JSON.parse(text);
          console.log("Gemini sohbet yanıtı başarıyla alındı!");
        } catch (geminiError) {
          console.error("Gemini API hatası (Sohbet yanıtı), Groq modeline geçiliyor:", geminiError);
        }
      }

      if (!aiResponse) {
        console.log("Groq API ile sohbet yanıtı oluşturuluyor...");
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
            response_format: { type: "json_object" }
          }),
        });

        if (!response.ok) {
          throw new Error(`Groq API returned status ${response.status}: ${await response.text()}`);
        }

        const result = await response.json();
        aiResponse = JSON.parse(result.choices[0].message.content);
      }
      const reply = aiResponse.reply;
      const mood = aiResponse.mood || 'neutral';
      const stressLevel = aiResponse.stress_level || 3;

      const { data: message } = await supabase
        .from('messages')
        .insert([{ session_id: sessionId, role: 'assistant', content: reply }])
        .select()
        .single();

      return new Response(JSON.stringify({
        ...message,
        mood,
        stress_level: stressLevel
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // POST /sessions/:id/hint (Canlı mentor ipucu getir)
    if (method === 'POST' && path.length === 3 && path[2] === 'hint') {
      const sessionId = path[1];

      try {
        const { data: history } = await supabase
          .from('messages')
          .select('role, content')
          .eq('session_id', sessionId)
          .order('created_at', { ascending: true })
          .limit(4);

        const { data: sessionData } = await supabase
          .from('sessions')
          .select('scenarios(context, title)')
          .eq('id', sessionId)
          .single();

        const systemPrompt = `Sen profesyonel bir iletişim koçu ve mentorsün. Kullanıcı şu senaryoda rol yapıyor: "${sessionData?.scenarios?.title || 'Persona Mirror'}" - "${sessionData?.scenarios?.context || ''}".
Kullanıcının karşıdaki karakterle empati kurarak, net ve kararlı bir iletişim yürütmesine yardımcı olacak kısa ve pratik bir ipucu ve örnek bir cümle ver.

Yalnızca aşağıdaki JSON yapısıyla yanıt ver:
{
  "tip": "İletişim ipucu (örn: Karşındakinin duygusunu onaylayarak başla.)",
  "suggested_reply": "Örnek söylenebilecek cümle..."
}

Lütfen bu JSON formatının dışına çıkma ve ekstra açıklama yapma.`;

        let aiResponse;

        if (GEMINI_API_KEY) {
          try {
            console.log("Gemini API ile ipucu oluşturuluyor...");
            const GEMINI_API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`;
            
            const geminiContents = [
              ...(history || []).map(m => ({
                role: m.role === 'assistant' ? 'model' : 'user',
                parts: [{ text: m.content }]
              })),
              {
                role: 'user',
                parts: [{ text: 'Nasıl yanıt vermeliyim? Bana kısa bir ipucu ve tek cümlelik örnek bir yanıt öner.' }]
              }
            ];

            const response = await fetch(GEMINI_API_URL, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({
                contents: geminiContents,
                systemInstruction: { parts: [{ text: systemPrompt }] },
                generationConfig: { responseMimeType: "application/json" }
              })
            });

            if (!response.ok) {
              throw new Error(`Gemini API returned status ${response.status}: ${await response.text()}`);
            }

            const result = await response.json();
            const text = result.candidates[0].content.parts[0].text;
            aiResponse = JSON.parse(text);
            console.log("Gemini ipucu başarıyla alındı!");
          } catch (geminiError) {
            console.error("Gemini API hatası (İpucu), Groq modeline geçiliyor:", geminiError);
          }
        }

        if (!aiResponse) {
          console.log("Groq API ile ipucu oluşturuluyor...");
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
                ...(history || []).map(m => ({ role: m.role, content: m.content })),
                { role: 'user', content: 'Nasıl yanıt vermeliyim? Bana kısa bir ipucu ve tek cümlelik örnek bir yanıt öner.' }
              ],
              response_format: { type: "json_object" }
            }),
          });

          if (!response.ok) {
            throw new Error(`Groq API error: ${response.status}`);
          }

          const result = await response.json();
          aiResponse = JSON.parse(result.choices[0].message.content);
        }

        return new Response(JSON.stringify({
          tip: aiResponse.tip || 'Karşı tarafın beklentisini ve duygularını anlamaya çalışarak yapıcı bir ton kullanın.',
          suggested_reply: aiResponse.suggested_reply || 'Sizi gayet iyi anlıyorum, bu konuda ortak bir yol bulabileceğimize inanıyorum.'
        }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });

      } catch (error) {
        console.error('Error in hint endpoint:', error);
        // Fallback: in case of any API error, return a premium helpful communication tip dynamically!
        return new Response(JSON.stringify({
          tip: 'Karşı tarafın duygularını ve endişelerini onaylayarak söze başlayın. Bu, savunma mekanizmasını kıracaktır.',
          suggested_reply: 'Duygularınızı ve bu konudaki çekincelerinizi anlıyorum. Gelin bunu iki taraf için de en uygun şekilde nasıl çözebileceğimizi konuşalım.'
        }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }
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
