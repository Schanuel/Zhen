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
