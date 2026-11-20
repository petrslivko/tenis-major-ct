create table if not exists public.tournament_state (
  id text primary key check (id = 'main'),
  data jsonb not null,
  updated_at timestamptz not null default clock_timestamp()
);

create table if not exists public.tournament_admins (
  user_id uuid primary key references auth.users (id) on delete cascade
);

alter table public.tournament_state enable row level security;
alter table public.tournament_admins enable row level security;

revoke all on table public.tournament_state from anon, authenticated;
grant select on table public.tournament_state to anon, authenticated;
grant update on table public.tournament_state to authenticated;
revoke all on table public.tournament_admins from anon, authenticated;

create or replace function public.is_tournament_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.tournament_admins
    where user_id = (select auth.uid())
  );
$$;

revoke all on function public.is_tournament_admin() from public, anon, authenticated;
grant execute on function public.is_tournament_admin() to authenticated;

drop policy if exists "Anyone can view tournament" on public.tournament_state;
create policy "Anyone can view tournament"
  on public.tournament_state for select
  to anon, authenticated
  using (true);

drop policy if exists "Tournament admins can update tournament" on public.tournament_state;
create policy "Tournament admins can update tournament"
  on public.tournament_state for update
  to authenticated
  using (public.is_tournament_admin())
  with check (public.is_tournament_admin());

create or replace function public.set_tournament_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := clock_timestamp();
  return new;
end;
$$;

drop trigger if exists set_tournament_updated_at on public.tournament_state;
create trigger set_tournament_updated_at
  before update on public.tournament_state
  for each row execute function public.set_tournament_updated_at();

insert into public.tournament_state (id, data)
values (
  'main',
  '{
    "teams": {
      "A": ["Dvojice A1", "Dvojice A2", "Dvojice A3", "Dvojice A4"],
      "B": ["Dvojice B1", "Dvojice B2", "Dvojice B3", "Dvojice B4"]
    },
    "scores": {},
    "playoff": {}
  }'::jsonb
)
on conflict (id) do nothing;

-- After creating the admin in Supabase Authentication, grant access with:
-- insert into public.tournament_admins (user_id)
-- values ('ADMIN-AUTH-USER-UUID');
