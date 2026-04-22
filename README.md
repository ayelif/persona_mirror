## Persona Mirror MVP

### Workspace
- `apps/web`: Next.js web app + API routes
- `apps/mobile`: Flutter mobile app
- `packages/shared-contracts`: shared request/response schemas
- `supabase/migrations`: SQL schema and RLS policies

### Run Web
1. Create `apps/web/.env.local`
2. Add:
   - `APP_JWT_SECRET=...`
   - `GOOGLE_CLIENT_ID=...` (optional in local)
   - `SUPABASE_URL=...`
   - `SUPABASE_SERVICE_ROLE_KEY=...`
   - `ANTHROPIC_API_KEY=...`
3. Run:
   - `npm install`
   - `npm run dev:web`

### Run Mobile
- `cd apps/mobile`
- `flutter pub get`
- `flutter run`

### Notes
- Local MVP can run without external integrations; API falls back to in-memory data.
- For production, configure Supabase + Google + Anthropic environment values.
