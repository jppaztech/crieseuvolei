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
2. Copie `.env.example` para `.env` e preencha os valores do Supabase.
3. Carregue as variáveis no terminal (o projeto não carrega `.env` automaticamente):

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

O site deve estar vinculado ao repositório e usar `netlify.toml`. No painel **Site configuration > Environment variables**, configure para o contexto de produção:

| Variável | Valor |
|---|---|
| `SUPABASE_URL` | URL HTTPS do projeto Supabase |
| `SUPABASE_PUBLISHABLE_KEY` | chave publishable/anon do projeto |
| `APP_BASE_URL` | `https://crieseuvolei.netlify.app` |
| `APP_LANGUAGE_DEFAULT` | `pt-BR` ou `en-US` |

Não configure `SUPABASE_SECRET_KEY` ou `service_role` neste site estático. O build de produção falha explicitamente se URL/chave pública estiverem ausentes.

Para publicar manualmente em uma sessão Netlify autenticada:

```bash
npx netlify-cli deploy --prod --dir .
```

## Modelo de acesso

- **Espectador:** sem conta, consulta somente torneios públicos em andamento.
- **Responsável:** cria e controla seu torneio.
- **Co-admin:** aceita convite direcionado ao e-mail da conta; pode editar aquele torneio, sem acesso global.
- **Admin da plataforma:** manutenção geral somente com `app_metadata.platform_admin` definido por operador confiável.

As políticas RLS no banco são a autoridade final; as verificações da interface são apenas apresentação.

## Checklist de publicação

- [ ] Aplicar `supabase/schema.sql` no projeto Supabase de produção.
- [ ] Configurar Site URL e Redirect URLs no Supabase Auth.
- [ ] Revisar template de confirmação e remetente de e-mail no Supabase.
- [ ] Configurar as quatro variáveis públicas no Netlify.
- [ ] Confirmar que o build de produção concluiu.
- [ ] Testar cadastro, confirmação, login, redefinição de senha e logout.
- [ ] Testar criação de torneio, convite/aceite com outra conta e isolamento entre usuários.
- [ ] Testar visibilidade pública, pesquisa, placar ao vivo e bloqueio de empate.
- [ ] Conferir o site publicado em desktop e celular.
- [ ] Instalar a PWA e confirmar que o shell abre offline; validar que operações exibem estado sem conexão.

## Direitos autorais e licença

© 2026 João Paz — Criação e desenvolvimento do CrieSeuVôlei.
O código é distribuído sob a licença MIT; consulte `LICENSE`.
