-- Open the board to all of F3 Nation.
-- Identity becomes a per-device id so F3 names can repeat across regions and a man can fix his name/region freely.

alter table public.f3_pushups add column if not exists device_id text;
update public.f3_pushups set device_id = gen_random_uuid()::text where device_id is null;
alter table public.f3_pushups alter column device_id set not null;
alter table public.f3_pushups alter column region set default 'F3 Nation';

-- replace the old (region, name_key, day) uniqueness with (device_id, day)
alter table public.f3_pushups drop constraint if exists f3_pushups_region_name_key_day_key;
alter table public.f3_pushups add constraint f3_pushups_device_day unique (device_id, day);
create index if not exists f3_pushups_device on public.f3_pushups (device_id);

drop view if exists public.f3_board;
create view public.f3_board with (security_invoker = true) as
select
  device_id,
  (array_agg(region  order by updated_at desc))[1]                  as region,
  (array_agg(f3_name order by updated_at desc))[1]                  as f3_name,
  sum(count)::int                                                   as total,
  count(*) filter (where count > 0)::int                            as days_logged,
  count(*) filter (where count >= daily_goal)::int                  as days_done,
  coalesce(sum(count) filter (where day = (now() at time zone 'America/New_York')::date), 0)::int as today_count,
  max(day)                                                          as last_day,
  max(updated_at)                                                   as updated_at
from public.f3_pushups
group by device_id
having sum(count) > 0;

grant select on public.f3_board to anon, authenticated;
