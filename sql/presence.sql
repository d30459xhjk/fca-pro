-- Who's online (dev-only view in the app toolbar).
-- Every signed-in client upserts its own row every 30s; only dev@fcapro.app
-- can see the panel, but anyone signed in may read the table.
-- Safe to re-run.

create table if not exists public.presence (
  email     text primary key,
  last_seen timestamptz not null default now()
);

alter table public.presence enable row level security;

drop policy if exists presence_read on public.presence;
create policy presence_read on public.presence
  for select to authenticated
  using (true);

drop policy if exists presence_upsert on public.presence;
create policy presence_upsert on public.presence
  for insert to authenticated
  with check (email = auth.jwt() ->> 'email');

drop policy if exists presence_update on public.presence;
create policy presence_update on public.presence
  for update to authenticated
  using (email = auth.jwt() ->> 'email')
  with check (email = auth.jwt() ->> 'email');

grant select, insert, update on public.presence to authenticated;

-- housekeeping: drop rows nobody has touched in a month
delete from public.presence where last_seen < now() - interval '30 days';
