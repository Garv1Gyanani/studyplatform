-- Add functions for points and leaderboard support

-- 1. Increment Points Function
create or replace function public.increment_points(user_id uuid, points_to_add int)
returns void as $$
begin
  update public.profiles
  set points = points + points_to_add,
      updated_at = now()
  where id = user_id;
end;
$$ language plpgsql security definer;

-- 2. Materialized view for Leaderboard (for performance)
create or replace view public.leaderboard as
select 
  id,
  username,
  avatar_url,
  points,
  rank() over (order by points desc) as rank
from public.profiles
where role = 'student'
order by points desc;
