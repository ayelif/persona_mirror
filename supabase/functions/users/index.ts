// @ts-nocheck
import { handleCors, corsHeaders } from '../_shared/cors.ts';
import { createAdminClient } from '../_shared/supabaseClient.ts';

Deno.serve(async (req) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  const supabase = createAdminClient();
  const { method } = req;
  const url = new URL(req.url);
  const userId = url.searchParams.get('id');

  try {
    // CREATE (Registration)
    if (method === 'POST') {
      const { email, google_sub_id } = await req.json();
      
      const { data, error } = await supabase
        .from('users')
        .insert([{ email, google_sub_id }])
        .select()
        .single();

      if (error) throw error;
      return new Response(JSON.stringify(data), {
        status: 201,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // READ
    if (method === 'GET') {
      if (!userId) {
        throw new Error('User ID is required for GET');
      }

      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('id', userId)
        .single();

      if (error) throw error;
      return new Response(JSON.stringify(data), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // UPDATE
    if (method === 'PATCH' || method === 'PUT') {
      if (!userId) {
        throw new Error('User ID is required for UPDATE');
      }

      const updates = await req.json();
      const { data, error } = await supabase
        .from('users')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

      if (error) throw error;
      return new Response(JSON.stringify(data), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // DELETE
    if (method === 'DELETE') {
      if (!userId) {
        throw new Error('User ID is required for DELETE');
      }

      const { error } = await supabase
        .from('users')
        .delete()
        .eq('id', userId);

      if (error) throw error;
      return new Response(JSON.stringify({ message: 'User deleted successfully' }), {
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
