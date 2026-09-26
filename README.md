# CrieSeuVôlei

Aplicação web para criar torneios de vôlei, organizar jogadores e partidas, lançar resultados e acompanhar jogos ao vivo. A interface está disponível em português do Brasil e inglês dos Estados Unidos.

**Produção:** https://crieseuvolei.netlify.app/

## O que a aplicação oferece

- visitantes acompanham torneios públicos em andamento sem login;
- usuários criam conta e torneios independentes;
- com **Confirm email** desativado no Supabase, o cadastro usa e-mail e senha sem confirmação; a recuperação de senha permanece por e-mail;
- responsável e co-admins gerenciam os dados do torneio;
- convites de co-admin são exclusivos, de uso único, expiram em 30 dias e podem ser copiados ou compartilhados pelo WhatsApp;
- partidas e placares são persistidos no Supabase e atualizados em tempo real;
- sorteio equilibrado, classificação, semifinais, disputa de 3º lugar, final, encerramento e pódio;
- placares concluídos podem ser corrigidos antes do encerramento; a agenda não pode ser regenerada depois de iniciada;
- alterações simultâneas de co-admins usam controle de versão para não sobrescrever silenciosamente dados mais recentes;
- exportação de times, agenda completa e pódio em JPEG ou PDF.

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

1. Em banco existente, aplique a migração incremental mais recente em `supabase/migrations/` pelo **SQL Editor**. Em uma instalação nova, aplique `supabase/schema.sql`. A migração de convite expira links pendentes antigos, sem apagar torneios ou placares.
2. Em **Authentication > URL Configuration**, defina `https://crieseuvolei.netlify.app/` como Site URL e permita `https://crieseuvolei.netlify.app/**` em Redirect URLs. Para desenvolvimento, permita também `http://localhost:8000/**`.
3. Em **Authentication > Providers > Email**, desative **Confirm email** para permitir cadastro com e-mail e senha sem etapa de confirmação. O Supabase Auth continua impedindo a reutilização de um e-mail já cadastrado.
4. Mantenha a recuperação de senha habilitada. Configure um remetente SMTP transacional antes de abrir a redefinição de senha ao público; a entrega padrão do Supabase tem restrições e limites e não é indicada para produção. O redirecionamento de cadastro/recuperação deve aceitar a URL base do site.
5. O dono da aplicação só recebe acesso de manutenção geral se um operador confiável definir `app_metadata.platform_admin = true` para a conta dele no painel/API administrativa do Supabase. Não use `user_metadata` para esta permissão: o próprio usuário pode editar esse campo.

O schema aplica isolamento por `owner_id`/membro, limita leitura pública a torneios `live` e fecha a tabela legada `app_state` removendo suas políticas antigas. Criar/aceitar convites é feito por funções SQL com validação da sessão e do e-mail autenticado. Os dados de e-mail do responsável não são expostos na consulta pública de torneios.

### Convites

O responsável ou co-admin informa o e-mail da pessoa. O banco registra o convite e vincula um token aleatório, de uso único, ao e-mail informado. O app oferece **copiar link** ou **compartilhar pelo WhatsApp**; não envia convite por e-mail. O convidado precisa criar conta ou entrar com o mesmo e-mail e abrir o link. Tokens antigos sem validade são expirados ao aplicar a migração. Não compartilhe o link publicamente: qualquer pessoa com acesso ao link e à conta do e-mail convidado pode aceitá-lo.

## Fluxo e regras do torneio

1. Entrar ou criar uma conta e criar um torneio pelo nome.
2. Definir quantidade de jogadores, times e rodadas; a quantidade de jogadores precisa dividir igualmente entre os times, com pelo menos dois por time.
3. Cadastrar jogadores e nível de habilidade (1 a 5), nomear os times, sortear escalações equilibradas e exportar a relação de times/jogadores.
4. Gerar a agenda uma única vez; registrar os placares e, enquanto aberto, corrigir resultados concluídos. O botão de geração deixa de existir depois que a agenda começa.
5. A classificação usa vitórias, saldo de pontos e pontos marcados. Os quatro primeiros avançam para semifinais (1º×4º e 2º×3º), depois disputa de 3º lugar e final.
6. Encerrar o torneio após preencher os dois placares finais para publicar o pódio e exportar o relatório.

As exportações JPEG/PDF carregam `html2canvas` e `html2pdf.js` de CDN e, portanto, precisam de conexão no momento de gerar os arquivos.

### SMTP para recuperação de senha

Para permitir recuperação de senha confiável a qualquer usuário, escolha um provedor de e-mail transacional (por exemplo, Resend), confirme um domínio que você controla nesse provedor e publique no DNS os registros de autenticação solicitados (SPF/DKIM e, se recomendado, DMARC). Depois:

1. No provedor, obtenha host, porta, usuário e senha SMTP, e valide um endereço remetente do seu domínio.
2. No painel Supabase, abra **Project Settings > Authentication > SMTP Settings** (os nomes podem variar) e habilite o envio SMTP personalizado.
3. Informe host, porta, usuário, senha e remetente; mantenha esses segredos somente no painel seguro do Supabase, nunca no frontend, Git ou chat.
4. Envie um teste de redefinição para um endereço que não faça parte da equipe Supabase e confirme a chegada. A conta no provedor e o domínio são pré-requisitos; não foram criados/configurados pelo repositório.

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
- [x] Aplicar e verificar a migração incremental de convites tokenizados no Supabase de produção; o token não é legível pela API autenticada.
- [x] Ativar cadastro sem confirmação no Supabase Auth e preservar Site URL/Redirect URLs.
- [ ] Configurar e testar SMTP personalizado para recuperação de senha pública.
- [x] Declarar URL e credencial publishable do Supabase, URL base e idioma no `netlify.toml`.
- [x] Publicar a versão de múltiplos torneios no site de produção pelo fluxo GitHub → Netlify.
- [x] Verificar em produção o HTML inicial, configuração pública, manifesto PWA e consulta REST de torneios ao vivo.
- [x] Passar no deploy preview do Netlify, incluindo `npm test` e build para o fluxo restaurado.
- [x] Publicar no Netlify a restauração do fluxo de torneio por etapas e convites tokenizados.
- [ ] Testar cadastro sem confirmação, login, redefinição de senha e logout.
- [ ] Testar criação de torneio, convite/aceite de uso único com outra conta e isolamento entre usuários.
- [ ] Testar sorteio, agenda, classificação, edição de placar, semifinais, final, encerramento e exportações.
- [ ] Testar visibilidade pública, pesquisa e bloqueio de empate.
- [ ] Conferir o site publicado em desktop e celular.
- [ ] Instalar a PWA de produção e confirmar que o shell abre offline; validar que operações exibem estado sem conexão.

`npm test`, `npm run build` e `npm audit` verificam sintaxe, traduções, manifesto/service worker, regras de torneio, contratos estáticos de RLS/convite, bloqueio de chaves secretas, build e vulnerabilidades conhecidas. Em 26/09/2026, após correção de uma asserção no teste do round-robin, `npm test` e `npm run build` passaram localmente em Node.js 24.19.0 para esta alteração; o Netlify executa os mesmos testes com Node.js 20 antes de cada publicação. Esses testes não substituem a validação de duas contas no projeto Supabase real.

### Estado desta publicação

Em 26/09/2026, além do schema anterior, foi aplicada a migração incremental `20260925220000_convites_tokenizados_uso_unico.sql` no Supabase de produção. A verificação remota confirmou as colunas do token e expiração, o RPC de aceite por token, a remoção do RPC legado por ID, a permissão de execução para usuários autenticados e a impossibilidade de ler o token pela API. Também foi ativado `mailer_autoconfirm`; a URL do site e a lista de redirecionamentos permaneceram inalteradas. SMTP personalizado não está configurado.

A versão restaurada passou no deploy preview do Netlify após corrigir uma asserção do teste automatizado; `npm test` e `npm run build` também passaram localmente. O commit `5346782` foi publicado em produção pelo Netlify em 26/09/2026. A URL principal, `runtime-config.js`, manifesto PWA, service worker e os módulos do fluxo de torneio responderam HTTP 200; a consulta REST pública do Supabase e a configuração sem chave secreta também foram verificadas. Cadastro real, redefinição de senha, convite/aceite com duas contas, isolamento ponta a ponta e geração visual dos JPEG/PDF ainda precisam de validação funcional pelo responsável; verificações técnicas não substituem esses testes.

## Direitos autorais e licença

© 2026 João Paz — Criação e desenvolvimento do CrieSeuVôlei.
O código é distribuído sob a licença MIT; consulte `LICENSE`.
