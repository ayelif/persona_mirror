// @ts-nocheck
import { handleCors, corsHeaders } from '../_shared/cors.ts';

Deno.serve(async (req) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  return new Response(JSON.stringify({ message: "Auth function is ready" }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
});
