export const env = {
  anthropicApiKey: process.env.ANTHROPIC_API_KEY ?? '',
  supabaseUrl: process.env.SUPABASE_URL ?? '',
  supabaseServiceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY ?? '',
  appJwtSecret: process.env.APP_JWT_SECRET ?? 'dev-secret',
  googleClientId: process.env.GOOGLE_CLIENT_ID ?? '',
};

export const hasExternalIntegrations =
  env.anthropicApiKey.length > 0 &&
  env.supabaseUrl.length > 0 &&
  env.supabaseServiceRoleKey.length > 0;
