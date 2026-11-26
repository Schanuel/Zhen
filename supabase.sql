-- Zhen: banco de dados no Supabase
-- Como usar: Supabase > SQL Editor > New query > cole tudo > Run.
-- Pode rodar mais de uma vez sem problema.

-- Uma tabela guarda tudo de cada pessoa: calendários, atalhos, atividades, partidas e esportes.
create table if not exists public.registros (
  user_id       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  colecao       text not null check (colecao in ('calendarios', 'atalhos', 'atividades', 'tenis', 'esportes')),
  id            text not null,
  dados         jsonb not null default '{}'::jsonb,
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  primary key (user_id, colecao, id)
);

-- Regras de segurança (RLS): cada conta só enxerga e altera as próprias linhas.
alter table public.registros enable row level security;

drop policy if exists "ver os próprios registros" on public.registros;
create policy "ver os próprios registros" on public.registros
  for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists "criar os próprios registros" on public.registros;
create policy "criar os próprios registros" on public.registros
  for insert to authenticated with check ((select auth.uid()) = user_id);

drop policy if exists "editar os próprios registros" on public.registros;
create policy "editar os próprios registros" on public.registros
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

drop policy if exists "apagar os próprios registros" on public.registros;
create policy "apagar os próprios registros" on public.registros
  for delete to authenticated using ((select auth.uid()) = user_id);

-- Visitantes sem login não têm acesso nenhum.
revoke all on public.registros from anon;
grant select, insert, update, delete on public.registros to authenticated;

-- Mantém a data de atualização em dia.
create or replace function public.zhen_touch() returns trigger
language plpgsql as $$
begin
  new.atualizado_em := now();
  return new;
end $$;

drop trigger if exists registros_touch on public.registros;
create trigger registros_touch before update on public.registros
  for each row execute function public.zhen_touch();

-- ============================================================
-- Pausar uma conta sem apagar nada (ex.: pagamento atrasado)
-- Para pausar: Table Editor > pausados > Insert row > coloque o e-mail da pessoa.
-- Para liberar de novo: apague a linha dela nessa tabela.
-- ============================================================
create table if not exists public.pausados (
  email      text primary key,
  motivo     text,
  pausado_em timestamptz not null default now()
);
alter table public.pausados enable row level security;

-- cada pessoa só consegue ver se a própria conta está pausada (o site usa isso para mostrar o aviso)
drop policy if exists "ver se a própria conta está pausada" on public.pausados;
create policy "ver se a própria conta está pausada" on public.pausados
  for select to authenticated using (lower(email) = lower((select auth.jwt() ->> 'email')));
revoke all on public.pausados from anon;
grant select on public.pausados to authenticated;

-- verdadeiro quando a conta de quem está usando NÃO está pausada
create or replace function public.zhen_ativo() returns boolean
language sql stable security definer set search_path = public as $$
  select not exists (select 1 from public.pausados p where lower(p.email) = lower(auth.jwt() ->> 'email'))
$$;
revoke all on function public.zhen_ativo() from public, anon;
grant execute on function public.zhen_ativo() to authenticated;

-- as regras dos registros passam a exigir conta ativa (os dados de quem está pausado ficam guardados, só não abrem)
drop policy if exists "ver os próprios registros" on public.registros;
create policy "ver os próprios registros" on public.registros
  for select to authenticated using ((select auth.uid()) = user_id and (select public.zhen_ativo()));

drop policy if exists "criar os próprios registros" on public.registros;
create policy "criar os próprios registros" on public.registros
  for insert to authenticated with check ((select auth.uid()) = user_id and (select public.zhen_ativo()));

drop policy if exists "editar os próprios registros" on public.registros;
create policy "editar os próprios registros" on public.registros
  for update to authenticated using ((select auth.uid()) = user_id and (select public.zhen_ativo()))
  with check ((select auth.uid()) = user_id and (select public.zhen_ativo()));

drop policy if exists "apagar os próprios registros" on public.registros;
create policy "apagar os próprios registros" on public.registros
  for delete to authenticated using ((select auth.uid()) = user_id and (select public.zhen_ativo()));
