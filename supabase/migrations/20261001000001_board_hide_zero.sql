-- Hide men with no reps yet (e.g. after undoing everything) from the leaderboard.
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
group by region, name_key
having sum(count) > 0;
