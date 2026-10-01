-- F3 Pushup Challenge: one row per man per day, plus a leaderboard view.
-- Run this once in the Supabase SQL editor (or `supabase db push`).

create table if not exists public.f3_pushups (
  id          bigint generated always as identity primary key,
  region      text not null default 'Indy South',
  f3_name     text not null check (length(trim(f3_name)) between 1 and 30),
  name_key    text generated always as (lower(trim(f3_name))) stored,
  day         date not null,
  count       integer not null check (count between 0 and 5000),
  daily_goal  integer not null default 109 check (daily_goal between 1 and 2000),
  updated_at  timestamptz not null default now(),
  unique (region, name_key, day)
);

alter table public.f3_pushups enable row level security;

-- Honor system: anyone with the app can read the board and write their own rows by F3 name.
drop policy if exists "pax can read" on public.f3_pushups;
create policy "pax can read" on public.f3_pushups for select to anon, authenticated using (true);
drop policy if exists "pax can insert" on public.f3_pushups;
create policy "pax can insert" on public.f3_pushups for insert to anon, authenticated with check (true);
drop policy if exists "pax can update" on public.f3_pushups;
create policy "pax can update" on public.f3_pushups for update to anon, authenticated using (true) with check (true);
-- no delete policy: nothing can be erased from the client

create index if not exists f3_pushups_region_day on public.f3_pushups (region, day);

-- Leaderboard: one row per man.
create or replace view public.f3_board with (security_invoker = true) as
select
  region,
  name_key,
  (array_agg(f3_name order by updated_at desc))[1]                 as f3_name,
  sum(count)::int                                                   as total,
  count(*) filter (where count > 0)::int                            as days_logged,
  count(*) filter (where count >= daily_goal)::int                  as days_done,
  coalesce(sum(count) filter (where day = (now() at time zone 'America/Indiana/Indianapolis')::date), 0)::int as today_count,
  max(day)                                                          as last_day,
  max(updated_at)                                                   as updated_at
from public.f3_pushups
group by region, name_key;

grant select on public.f3_board to anon, authenticated;
grant select, insert, update on public.f3_pushups to anon, authenticated;
