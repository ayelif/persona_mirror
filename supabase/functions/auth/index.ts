import { handleCors, corsHeaders } from '../_shared/cors.ts';
import { createAdminClient } from '../_shared/supabaseClient.ts';

Deno.serve(async (req) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  const supabase = createAdminClient();
  const { method } = req;

  try {
    if (method === 'POST') {
      const { id_token } = await req.json();
      
      if (!id_token) {
        throw new Error('id_token is required');
      }

      // 1. Google token doğrulama
      const googleRes = await fetch(`https://oauth2.googleapis.com/tokeninfo?id_token=${id_token}`);
      if (!googleRes.ok) {
        throw new Error('Invalid Google token');
      }
      
      const googleUser = await googleRes.json();
      const { email, sub: google_sub_id } = googleUser;

      // 2. Users tablosunda kontrol et
      let { data: user, error: userError } = await supabase
        .from('users')
        .select('*')
        .eq('google_sub_id', google_sub_id)
        .maybeSingle();

      if (userError) throw userError;

      if (!user) {
        // Yeni kullanıcı oluştur
        const { data: newUser, error: createError } = await supabase
          .from('users')
          .insert([{ email, google_sub_id }])
          .select()
          .single();
        
        if (createError) throw createError;
        user = newUser;
      }

      // Not: Normalde burada bir Supabase Auth session oluşturulmalı.
      // Şimdilik planın istediği gibi kullanıcı bilgisini ve bir "başarı" mesajını dönüyoruz.
      // JWT üretimi için supabase.auth.admin.createUser veya custom JWT kütüphanesi gerekebilir.
      
      return new Response(JSON.stringify({ user, message: 'Authenticated successfully' }), {
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

