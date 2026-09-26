# CrieSeuVôlei

Aplicação web para criar torneios de vôlei, organizar jogadores e partidas, lançar resultados e acompanhar jogos ao vivo. A interface está disponível em português do Brasil e inglês dos Estados Unidos.

**Produção:** https://crieseuvolei.netlify.app/

## O que a aplicação oferece

- visitantes acompanham torneios públicos em andamento sem login;
- usuários criam conta e torneios independentes;
- responsável e co-admins gerenciam os dados do torneio;
- convites de co-admin são registrados no banco e compartilhados por e-mail ou WhatsApp;
- partidas e placares são persistidos no Supabase e atualizados em tempo real;
- a validação não permite salvar partidas empatadas.

O primeiro acesso contém somente as duas ações principais — criar torneio e acompanhar jogos — e uma lista pesquisável dos torneios ao vivo. A configuração de partidas aparece depois de entrar no torneio.

O contrato visual está documentado em [`DESIGN.md`](DESIGN.md); os tokens para ferramentas de design ficam em `.impeccable/design.json`.

## Tecnologias

- HTML, CSS e JavaScript sem framework
- Supabase Auth, Postgres, RLS e Realtime
- Node.js/npm para gerar configuração e servir localmente
- PWA instalável com shell offline; login, sincronização e ações do torneio precisam de conexão
- Netlify para publicação

## Desenvolvimento local

1. Instale Node.js 18 ou superior.
2. Use `.env.example` como referência. Os comandos npm não carregam arquivos `.env` automaticamente.
3. Defina as variáveis no terminal antes de iniciar:

```powershell
$env:SUPABASE_URL="https://SEU_PROJETO.supabase.co"
$env:SUPABASE_PUBLISHABLE_KEY="SUA_CHAVE_PUBLISHABLE"
$env:APP_BASE_URL="http://localhost:8000"
$env:APP_LANGUAGE_DEFAULT="pt-BR"
npm run dev
```

Abra `http://localhost:8000`. Para verificar sintaxe e configuração:

```bash
npm test
npm run build
```

`runtime-config.js` é gerado durante o build, ignorado pelo Git e contém somente URL/chave publishable, URL base e idioma. A chave publishable/anon é pública por definição; **não** configure chave `secret` ou `service_role` no frontend, no build estático ou no Netlify.

## Configuração obrigatória do Supabase

1. Em **SQL Editor**, aplique `supabase/schema.sql`. O script é reaplicável e atualiza as tabelas/políticas existentes sem apagar torneios.
2. Em **Authentication > URL Configuration**, defina `https://crieseuvolei.netlify.app/` como Site URL e permita `https://crieseuvolei.netlify.app/**` em Redirect URLs. Para desenvolvimento, permita também `http://localhost:8000/**`.
3. Habilite confirmação de e-mail. O redirecionamento após a confirmação volta à aplicação; o usuário poderá então entrar.
4. Para personalizar a mensagem de confirmação, copie `supabase/templates/confirmation.html` para **Authentication > Email Templates > Confirm signup**. O template usa `{{ .ConfirmationURL }}` do Supabase.
5. O dono da aplicação só recebe acesso de manutenção geral se um operador confiável definir `app_metadata.platform_admin = true` para a conta dele no painel/API administrativa do Supabase. Não use `user_metadata` para esta permissão: o próprio usuário pode editar esse campo.

O schema aplica isolamento por `owner_id`/membro, limita leitura pública a torneios `live` e fecha a tabela legada `app_state` removendo suas políticas antigas. Criar/aceitar convites é feito por funções SQL com validação da sessão e do e-mail autenticado. Os dados de e-mail do responsável não são expostos na consulta pública de torneios.

### Convites

O responsável ou co-admin informa o e-mail da pessoa. O Supabase grava um convite pendente; os botões abrem um e-mail pré-preenchido ou o WhatsApp com o link. O convidado deve criar conta ou entrar **com o mesmo e-mail convidado** e abrir esse link para aceitar. O envio do e-mail é feito pelo aplicativo de e-mail do responsável, não por um serviço transacional próprio do CrieSeuVôlei.

## Netlify

O site deve estar vinculado ao repositório e usar `netlify.toml`. URL, chave publishable, URL base e idioma padrão estão declarados no contexto de produção desse arquivo; se usar variáveis do painel **Site configuration > Environment variables**, mantenha os mesmos nomes/valores para que a configuração do site não diverja do repositório:

| Variável | Valor |
|---|---|
| `SUPABASE_URL` | URL HTTPS do projeto Supabase |
| `SUPABASE_PUBLISHABLE_KEY` | chave publishable/anon do projeto |
| `APP_BASE_URL` | `https://crieseuvolei.netlify.app` |
| `APP_LANGUAGE_DEFAULT` | `pt-BR` ou `en-US` |

`SUPABASE_PUBLISHABLE_KEY` é uma chave pública, destinada ao navegador, e não concede acesso sem as políticas RLS. Não configure `SUPABASE_SECRET_KEY` ou `service_role` neste site estático. O build de produção falha explicitamente se URL/chave pública estiverem ausentes.

O deploy contínuo do repositório é preferível. Para publicar manualmente, instale/execute o CLI oficial em uma sessão Netlify autenticada:

```bash
npx netlify-cli@latest deploy --prod --dir .
```

O Netlify CLI não é uma dependência da aplicação; assim, ferramentas de publicação não entram no bundle nem ampliam a superfície de dependências do site. A aplicação usa `http-server` somente para desenvolvimento.

## Modelo de acesso

- **Espectador:** sem conta, consulta somente torneios públicos em andamento.
- **Responsável:** cria e controla seu torneio.
- **Co-admin:** aceita convite direcionado ao e-mail da conta; pode editar aquele torneio, sem acesso global.
- **Admin da plataforma:** manutenção geral somente com `app_metadata.platform_admin` definido por operador confiável.

As políticas RLS no banco são a autoridade final; as verificações da interface são apenas apresentação.

## Checklist de publicação

- [x] Reinstalar dependências pelo lockfile com `npm ci`.
- [x] Rodar `npm test`.
- [x] Rodar `npm audit` sem vulnerabilidades conhecidas.
- [x] Rodar build local via Netlify CLI no contexto `production`.
- [x] Aplicar o schema versionado no projeto Supabase de produção e confirmar tabelas, funções RPC, RLS e permissões por coluna.
- [x] Configurar Site URL e Redirect URLs no Supabase Auth.
- [ ] Revisar template de confirmação e remetente de e-mail no Supabase.
- [x] Declarar URL e credencial publishable do Supabase, URL base e idioma no `netlify.toml`.
- [ ] Confirmar que o deploy atualizado concluiu no site de produção.
- [ ] Testar cadastro, confirmação, login, redefinição de senha e logout.
- [ ] Testar criação de torneio, convite/aceite com outra conta e isolamento entre usuários.
- [ ] Testar visibilidade pública, pesquisa, placar ao vivo e bloqueio de empate.
- [ ] Conferir o site publicado em desktop e celular.
- [ ] Instalar a PWA de produção e confirmar que o shell abre offline; validar que operações exibem estado sem conexão.

`npm test`, `npm run build` e `npm audit` verificam localmente sintaxe, traduções, manifesto/service worker, contratos estáticos de RLS/convite, bloqueio de chaves secretas, build e vulnerabilidades conhecidas. Esses testes não substituem a validação de duas contas no projeto Supabase real.

### Estado desta publicação

Em 25/09/2026, o schema de produção foi aplicado por uma sessão autenticada do Supabase Management API. A verificação remota confirmou as quatro tabelas de torneios/perfis, RLS habilitado, políticas de isolamento, funções de convite e permissões por coluna: espectadores não podem escrever nem ler e-mails privados; usuários autenticados podem criar torneios. O endpoint público REST reconhece a tabela. As URLs de autenticação do Supabase também foram atualizadas para o domínio de produção e o endereço local de desenvolvimento.

O deploy da versão atualizada ainda depende de integrar esta branch à branch `main`, configurada como branch de produção no Netlify, e aguardar a build/publicação remota. A build do Netlify deve executar `npm run build` a partir do `netlify.toml`. Cadastro/confirmação de e-mail e aceite de convite com duas contas distintas ainda precisam de validação ponta a ponta; as verificações de banco e API não substituem esse teste com caixas de e-mail acessíveis. Não anunciar a publicação como concluída até confirmar o novo deploy e percorrer o checklist acima.

## Direitos autorais e licença

© 2026 João Paz — Criação e desenvolvimento do CrieSeuVôlei.
O código é distribuído sob a licença MIT; consulte `LICENSE`.
