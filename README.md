# Zhen com contas (Supabase)

Nesta pasta:

- `index.html`: o site, com tela de entrar e criar conta.
- `supabase.sql`: cria o banco de dados e as regras para cada conta ver só os próprios dados.

## 1. Criar o banco no Supabase

1. Entre no seu projeto em supabase.com.
2. Abra **SQL Editor** → **New query**.
3. Cole todo o conteúdo de `supabase.sql` e clique em **Run**.
   Deve aparecer "Success. No rows returned".

## 2. Ligar o site ao seu projeto

1. No Supabase, abra **Project Settings** → **API**.
2. Copie a **Project URL** (algo como `https://abcd1234.supabase.co`).
3. Copie a chave **anon public**.
   Use só a **anon**. Nunca coloque a chave `service_role` no site.
4. Abra `index.html` num editor de texto (Bloco de Notas, VS Code…) e procure por `COLE_AQUI`.
5. Troque `COLE_AQUI_A_PROJECT_URL` pela URL e `COLE_AQUI_A_ANON_KEY` pela chave. Mantenha as aspas.

A chave anon pode ficar no site: ela é pública. Quem protege os dados de cada pessoa são as regras do passo 1.

## 3. Publicar o site (Netlify, grátis)

1. Entre em **app.netlify.com/drop**.
2. Arraste a pasta `zhen-app` (com o `index.html` já preenchido) para a página.
3. O Netlify gera um endereço, por exemplo `https://zhen-123.netlify.app`.
   Em **Site configuration** → **Change site name** dá para trocar o nome, por exemplo `https://meu-zhen.netlify.app`.

### Ou publicar pelo GitHub Pages (também grátis)

Se o site já estiver num repositório do GitHub:

1. No repositório, abra **Settings** → **Pages**.
2. Em **Source**, escolha **Deploy from a branch**.
3. Em **Branch**, escolha `main` e a pasta `/ (root)`, e clique em **Save**.
4. Depois de um ou dois minutos, o site fica em `https://SEU-USUARIO.github.io/NOME-DO-REPOSITORIO/`.

Cada vez que um arquivo muda no repositório, o site se atualiza sozinho.

## 4. Avisar o Supabase do endereço do site

Sem isso, os links de confirmação de e-mail e de "esqueci minha senha" não voltam para o site.

1. No Supabase, abra **Authentication** → **URL Configuration**.
2. Em **Site URL**, coloque o endereço do site, por exemplo `https://meu-zhen.netlify.app` ou `https://seu-usuario.github.io/zhen/`.
3. Em **Redirect URLs**, adicione o mesmo endereço.

## 5. Testar

1. Abra o site e crie uma conta.
2. Confirme o e-mail pelo link que chegar e entre.
3. Crie outra conta com outro e-mail: ela começa vazia e não vê nada da primeira.

## Dicas

- **Confirmação de e-mail:** por padrão o Supabase exige que a pessoa confirme o e-mail antes de entrar. Para desligar, vá em **Authentication** → **Sign In / Providers** → **Email** e desmarque **Confirm email**.
- **Limite de e-mails:** o envio de e-mails grátis do Supabase é limitado a poucos por hora. Para muita gente se cadastrando, configure um SMTP próprio em **Authentication** → **Emails** → **SMTP Settings**.
- **Atualizar o site:** depois de mudar o `index.html`, arraste a pasta de novo no Netlify, em **Deploys** → área de arrastar.
- **Seus dados antigos:** o que está salvo no site do claude.ai não vai sozinho para o Supabase. Se quiser levar algo, me peça.
