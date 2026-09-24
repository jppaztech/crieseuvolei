# CrieSeuVôlei

Aplicação web para criar e acompanhar torneios de vôlei, com gestão de placar, criação de torneios por usuários autenticados, convite de co-admins por torneio e visualização pública para espectadores.

Website: https://crieseuvolei.netlify.app/

Suporte: PT-BR e EN-US.

## Visão geral

O CrieSeuVôlei foi pensado para uso coletivo e realista:

- qualquer pessoa pode criar sua conta;
- o criador do torneio passa a ser responsável por ele;
- o responsável pode convidar co-criadores;
- espectadores podem acompanhar torneios públicos sem login;
- o dono da plataforma continua com acesso de manutenção geral.

A aplicação foi estruturada para funcionar em cenário multiusuário e multi-torneio, com isolamento por entidade e controle de acesso por torneio.

## Funcionalidades principais

- criação de torneios
- cadastro e login com Supabase Auth
- convite de co-admins por e-mail ou WhatsApp
- painel de administração por torneio
- acompanhamento público de torneios em andamento
- busca por nome do torneio
- registro de partidas e placar
- exibição do nome do torneio no topo da interface durante partidas
- suporte de idioma PT-BR e EN-US
- landing page moderna e responsiva

## Stack

- HTML5
- CSS3
- JavaScript
- Supabase Auth + Postgres
- Netlify
- Node.js para execução local

## Requisitos

- Node.js 18+
- npm
- projeto Supabase configurado
- acesso a URL pública do Netlify

## Execução local

```bash
npm install
npm run dev
```

Acesse:

```text
http://localhost:8000
```

## Variáveis de ambiente

Crie um arquivo `.env` ou use as variáveis do painel do Netlify com os valores do projeto Supabase:

```env
SUPABASE_URL=https://SEU_PROJETO.supabase.co
SUPABASE_KEY=SEU_PUBLISHABLE_KEY
SUPABASE_SECRET_KEY=SEU_SECRET_KEY
APP_BASE_URL=http://localhost:8000
APP_LANGUAGE_DEFAULT=pt-BR
```

Observações:

- nunca exponha `SUPABASE_SECRET_KEY` no cliente;
- use autenticação e RLS no Supabase para controle real de acesso;
- `APP_LANGUAGE_DEFAULT` pode ser `pt-BR` ou `en-US`.

## Configuração do Supabase

1. Crie um projeto no Supabase.
2. Configure a autenticação de e-mail.
3. Ative as políticas RLS para os dados dos torneios.
4. Aplique o schema de banco em `supabase/schema.sql`.
5. Confirme que as variáveis de ambiente e a URL pública do site estão corretas.

## Fluxo do produto

### Usuário visitante

- acessa a landing page;
- vê torneios públicos em andamento;
- pode buscar pelo nome do torneio;
- acompanha placares sem login.

### Responsável do torneio

- cria conta;
- cria o torneio;
- convida co-admins;
- registra/finaliza partidas;
- gerencia pontos e informações do evento.

### Co-admin

- recebe convite;
- acessa o mesmo torneio;
- pode editar e atualizar o torneio conforme permissão.

### Manutenção da plataforma

- o responsável pela aplicação possui acesso geral para manutenção, upgrades e suporte técnico.

## Deploy no Netlify

O projeto já está preparado para publicação no Netlify com a seguinte estrutura:

- `netlify.toml`
- `package.json`
- variáveis de ambiente no painel do Netlify

Comandos úteis:

```bash
npx netlify-cli deploy --prod
```

## Checklist de produção

- [x] landing page mais acolhedora
- [x] fluxo de criação de torneio
- [x] acompanhamento público
- [x] suporte PT-BR / EN-US
- [x] nome do torneio visível durante as partidas
- [x] cadastro e login com autenticação
- [x] modelo multi-torneio e multiusuário
- [x] convite de co-admins
- [x] documentação atualizada
- [x] configuração de deploy no Netlify

## Direitos autorais

© 2026 João Paz. Todos os direitos reservados sobre a criação e manutenção desta aplicação.

## Licença

Este projeto está licenciado sob a MIT License.

Como esta é uma aplicação HTML estática, a URL do projeto e a chave **publishable/anon**
são informadas na inicialização do cliente em `index.html`:

```javascript
const SUPABASE_URL = 'https://seu-projeto.supabase.co'
const SUPABASE_KEY = 'sua-chave-publishable'
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY)
```

A chave publishable/anon pode aparecer no navegador, mas nunca coloque uma chave
`service_role` no frontend. A proteção deve ser feita com autenticação e RLS.

### 3. Criar Tabelas no Banco de Dados

Use o schema pronto em `supabase/schema.sql` para permitir que várias pessoas criem, convidem e gerenciem seus torneios em paralelo:

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT,
  is_admin BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.tournaments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  owner_email TEXT NOT NULL,
  scorer_emails TEXT[] NOT NULL DEFAULT '{}',
  invite_emails TEXT[] NOT NULL DEFAULT '{}',
  is_public BOOLEAN NOT NULL DEFAULT TRUE,
  game_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.tournament_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tournament_id UUID NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('owner', 'editor', 'viewer')) DEFAULT 'editor',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tournament_id, user_id),
  UNIQUE (tournament_id, email)
);

CREATE TABLE IF NOT EXISTS public.tournament_invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tournament_id UUID NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
  inviter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  invited_email TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('editor', 'viewer')) DEFAULT 'editor',
  status TEXT NOT NULL CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')) DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tournament_id, invited_email)
);
```

O fluxo real de autenticação e co-criação funciona assim:

- qualquer pessoa pode criar uma conta no app;
- o primeiro usuário autenticado a criar ou assumir um torneio vira responsável;
- o responsável pode convidar co-criadores por e-mail;
- os operadores autorizados podem editar o torneio sem virar administradores globais;
- o público pode visualizar o painel de torneios em andamento, mas não alterar dados.

Crie pelo menos um usuário em **Authentication > Users** para o login administrativo.
O primeiro carregamento pode mostrar um aviso se a tabela, as políticas ou o Realtime
estiverem incompletos.

### 4. Configuração do deploy em Netlify / Vercel

Para uso real em produção, configure as variáveis de ambiente do deploy e mantenha apenas
os valores públicos do cliente (URL e chave publishable do Supabase):

```bash
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_KEY=sua-chave-publishable
APP_BASE_URL=https://seu-site.netlify.app
APP_LANGUAGE_DEFAULT=pt-BR
```

No Netlify ou Vercel, mantenha isso em **Environment variables**; nunca exponha uma
`service_role` ou segredo no HTML. Essa aplicação é um front-end estático e depende dos
controles de acesso e RLS do banco para manter o ambiente seguro.

Checklist de deploy em Netlify:

- [ ] criar projeto no Netlify com o repositório do app;
- [ ] confirmar que `netlify.toml` está no repositório;
- [ ] definir `SUPABASE_URL` e `SUPABASE_KEY` como variáveis do ambiente;
- [ ] confirmar que a função de login e o painel público estão ativos;
- [ ] validar o domínio final e testar o login em produção;
- [ ] verificar se o app atualiza mensagem de idioma PT-BR / EN-US corretamente.

### Modelo para uso geral e multi-torneios

O modelo implementado agora segue a decisão de uso geral em múltiplos torneios:

- cada torneio possui um **responsável** e uma lista de **operadores**;
- o primeiro usuário autenticado que cria um torneio vira seu responsável;
- o responsável pode adicionar ou remover operadores para esse torneio;
- operadores podem lançar e corrigir pontos, mas não assumem a gestão global da aplicação;
- várias pessoas podem criar seus próprios torneios no mesmo app e no mesmo Supabase, sem misturar dados;
- quando o volume de dados cresce, a estratégia recomendada é manter apenas o último torneio ativo por responsável para reduzir custo e manutenção, mas a arquitetura já foi evoluída para suportar múltiplos torneios ao mesmo tempo.

Para o estado atual, essa autorização continua sendo persistida no `game_data`, com campos como:

```json
{
  "ownerEmail": "responsavel@exemplo.com",
  "scorerEmails": ["operador1@exemplo.com", "operador2@exemplo.com"]
}
```

A estrutura real de persistência foi migrada para a tabela `tournaments`, com um registro por torneio:

```sql
CREATE TABLE tournaments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  owner_email TEXT NOT NULL,
  scorer_emails TEXT[] NOT NULL DEFAULT '{}',
  game_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

Esse modelo já atende ao caso de vários usuários e vários torneios simultâneos. Se em algum momento a base crescer demais, a otimização pode ser feita mantendo apenas o torneio ativo mais recente por responsável, sem perder a capacidade de criar múltiplos torneios no mesmo sistema.

## ✅ Checklist de preparação para uso e deploy

- [ ] Node.js 18+ disponível para uso local com `npm run dev`;
- [ ] `npm install` executado com sucesso;
- [ ] `supabase/schema.sql` aplicado no projeto do Supabase;
- [ ] políticas RLS criadas para `profiles`, `tournaments`, `tournament_members` e `tournament_invites`;
- [ ] usuário administrativo autenticado no Supabase;
- [ ] a app acessa a URL do projeto e a chave pública do Supabase sem expor segredo;
- [ ] tela pública com torneios em andamento funcional;
- [ ] criação de conta, login e convite de co-criador funcionando;
- [ ] ruído de ícones/teclas e pontuação sem empate devidamente validado;
- [ ] deploy em Netlify validado com o domínio final e acessos reais.

## 🤝 Contribuindo

Contribuições são bem-vindas! Siga os passos abaixo:

### 1. Fork o Repositório
```bash
# Clique no botão "Fork" no GitHub
```

### 2. Clone Seu Fork
```bash
git clone https://github.com/jppaztech/crieseuvolei.git
cd crieseuvolei
```

### 3. Crie uma Branch
```bash
git checkout -b feature/sua-funcionalidade
# Exemplo:
git checkout -b feature/adicionar-tabela-rankings
```

### 4. Faça Suas Alterações
```bash
# Edite os arquivos
# Teste suas mudanças localmente
```

### 5. Commit e Push
```bash
git add .
git commit -m "Descrição clara das mudanças"
# Exemplos de mensagens:
# - "feat: adicionar tabela de rankings"
# - "fix: corrigir atualização de placar em tempo real"
# - "docs: melhorar documentação de setup"
git push origin feature/sua-funcionalidade
```

### 6. Abra um Pull Request
- Vá para o repositório original no GitHub
- Clique em "New Pull Request"
- Descreva suas mudanças claramente
- Aguarde revisão

### Padrão de Commits
```
feat:     Nova funcionalidade
fix:      Correção de bug
docs:     Alteração na documentação
style:    Formatação/estilo de código
refactor: Reorganização de código
test:     Adição de testes
```

## 🔧 Troubleshooting

### Problema: Placar não atualiza em tempo real

**Solução:**
1. Verifique a conexão com a internet
2. Abra o console do navegador (F12)
3. Procure por erros de conexão com Supabase
4. Verifique as credenciais do Supabase

### Problema: PDF não é gerado

**Solução:**
1. Verifique se as bibliotecas CDN estão carregando:
   - `html2canvas`
   - `html2pdf.js`
2. Certifique-se de que todos os dados estão preenchidos
3. Tente usar navegador Chrome (melhor suporte)

### Problema: Interface distorcida em mobile

**Solução:**
1. Limpe o cache do navegador (Ctrl+Shift+Del)
2. Atualize a página
3. Verifique se o viewport está configurado corretamente
4. Teste em incógnito

### Problema: Dados não salvam na nuvem

**Solução:**
1. Verifique as permissões no Supabase
2. Valide que as chaves de acesso estão corretas
3. Verifique a estrutura das tabelas no banco
4. Procure por erros no console do navegador

## 🐛 Relatando Bugs

Se encontrar um bug, por favor:

1. **Verifique** se o problema já foi reportado em [Issues](../../issues)
2. **Descreva** o problema detalhadamente
3. **Inclua** prints ou vídeo do bug
4. **Liste** os passos para reproduzir
5. **Especifique** seu navegador e SO

### Template para Issue

```markdown
## Descrição do Bug
[Descreva o problema aqui]

## Passos para Reproduzir
1. 
2. 
3. 

## Comportamento Esperado
[O que deveria acontecer]

## Comportamento Atual
[O que realmente acontece]

## Ambiente
- Navegador: 
- SO: 
- Versão da App: 
```

## 🎨 Personalizando o Tema

As cores e estilos podem ser customizados editando as variáveis CSS no `index.html`:

```css
:root {
  --bg: #0f1115;           /* Cor de fundo */
  --card: #171a21;         /* Cor dos cards */
  --muted: #9aa4b2;        /* Cor muted/secundária */
  --text: #eef2f6;         /* Cor do texto */
  --accent: #22c55e;       /* Cor de destaque (verde) */
  --danger: #ef4444;       /* Cor de alerta/erro */
  --warn: #f59e0b;         /* Cor de aviso */
  --gap: 14px;             /* Espaçamento padrão */
  --radius: 14px;          /* Raio de border-radius */
}
```

## 📊 Performance

- **Tamanho do arquivo**: ~50KB (HTML + CSS + JS)
- **Tempo de carregamento**: < 2s em conexão 4G
- **Compatibilidade**: voltado para navegadores modernos; ainda não há matriz de testes automatizada
- **Acessibilidade**: melhorias são mantidas no código, mas a conformidade WCAG 2.1 AA ainda não foi auditada

## 🔐 Segurança

- Nunca coloque uma chave `service_role` ou outro segredo no frontend
- Use somente a chave publishable/anon no HTML e proteja os dados com RLS
- Restrinja a gravação de `app_state` a usuários autenticados
- Revise as políticas e usuários do Supabase antes de publicar

## 📞 Suporte
- **Email**: jpsantospaz@hotmail.com  
- **WhatsApp**: +55 81 99885-5027  
- Para dúvidas ou sugestões, entre em contato diretamente comigo.

## 📄 Licença
Este projeto está licenciado sob a MIT License – veja o arquivo LICENSE para detalhes.  
Mantido e supervisionado por João Paz.  

## ✍️ Autor
- **João Paz** – Desenvolvimento Inicial – [GitHub](https://github.com/jppaztech) | [LinkedIn](https://www.linkedin.com/in/joaospaz)

## 🙏 Agradecimentos
- [Supabase](https://supabase.com) – Backend em tempo real  
- [html2canvas](https://html2canvas.hertzen.com/) – Captura de elementos  
- [html2pdf.js](http://html2pdf.net/) – Geração de PDF  
- [Google Fonts](https://fonts.google.com/) – Tipografia  

## 🚀 Roadmap

### v1.1
- [ ] Sistema de rankings e histórico
- [ ] Histórico de torneios separados por usuário
- [ ] Pontuação por sets e critérios de desempate
- [ ] Temas adicionais
- [ ] Notificações em tempo real
- [ ] Integração com WhatsApp/Telegram

### v1.2
- [ ] Aplicativo mobile nativo
- [ ] Modo offline
- [ ] Sincronização automática
- [ ] Dashboard de estatísticas avançadas

### v2.0
- [ ] Sistema de usuários e autenticação
- [ ] Organização de torneios
- [ ] Chat em tempo real
- [ ] Análise de performance com IA

---

**Desenvolvido com ❤️ por um amante de vôlei**

## Contribuição
Contribuições são bem-vindas!  
Se você deseja melhorar este projeto, faça um fork do repositório e envie um pull request.  
**Importante:** qualquer alteração, mesmo pequena, deve ser aprovada previamente por mim antes de ser incorporada.  
Para mudanças maiores, abra uma issue primeiro para discutirmos o que você gostaria de modificar.
