create extension if not exists "pgcrypto";

create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  google_sub_id varchar unique,
  email varchar unique,
  created_at timestamptz not null default now()
);

create table if not exists scenarios (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  title varchar(100) not null,
  context text not null,
  category varchar(50) not null,
  created_at timestamptz not null default now()
);

create table if not exists sessions (
  id uuid primary key default gen_random_uuid(),
  scenario_id uuid not null references scenarios(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  status varchar(20) not null default 'active',
  started_at timestamptz not null default now(),
  ended_at timestamptz
);

create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references sessions(id) on delete cascade,
  role varchar(10) not null check (role in ('user', 'assistant')),
  content text not null,
  created_at timestamptz not null default now()
);

create table if not exists analyses (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null unique references sessions(id) on delete cascade,
  empathy_score int not null check (empathy_score between 1 and 10),
  clarity_score int not null check (clarity_score between 1 and 10),
  assertiveness_score int not null check (assertiveness_score between 1 and 10),
  summary text not null,
  strengths text[],
  improvements text[],
  alternative_lines text[],
  share_image_url text,
  created_at timestamptz not null default now()
);

create index if not exists scenarios_user_id_idx on scenarios(user_id);
create index if not exists sessions_user_id_idx on sessions(user_id);
create index if not exists messages_session_id_idx on messages(session_id);
create index if not exists messages_created_at_idx on messages(created_at);

alter table users enable row level security;
alter table scenarios enable row level security;
alter table sessions enable row level security;
alter table messages enable row level security;
alter table analyses enable row level security;

create policy "users_self_select" on users for select using (auth.uid() = id);

create policy "scenarios_owner_access" on scenarios
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "sessions_owner_access" on sessions
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "messages_owner_access" on messages
for all using (
  exists (
    select 1 from sessions
    where sessions.id = messages.session_id
    and sessions.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from sessions
    where sessions.id = messages.session_id
    and sessions.user_id = auth.uid()
  )
);

create policy "analyses_owner_access" on analyses
for all using (
  exists (
    select 1 from sessions
    where sessions.id = analyses.session_id
    and sessions.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from sessions
    where sessions.id = analyses.session_id
    and sessions.user_id = auth.uid()
  )
);
