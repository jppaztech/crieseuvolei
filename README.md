# 🏐 CrieSeuVolei - Gerenciador de Peladas de Vôlei

![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Made with Supabase](https://img.shields.io/badge/Made%20with-Supabase-blue.svg)
![HTML5](https://img.shields.io/badge/HTML5-orange.svg)
![CSS3](https://img.shields.io/badge/CSS3-blue.svg)
![JavaScript](https://img.shields.io/badge/JavaScript-yellow.svg)
![Responsive Design](https://img.shields.io/badge/Responsive-Design-orange.svg)
![Status: Active](https://img.shields.io/badge/Status-Active-success.svg)

Uma aplicação web moderna e responsiva para gerenciar placar e resultado de partidas de vôlei em tempo real. Perfeita para peladas, treinos e competições amistosas.

## 🌐 Website (necessário login admin)
Acesse o projeto online: [CrieSeuVolei](https://crieseuvolei.netlify.app/)

## 📋 Sumário

- [Características](#-características)
- [Stack Tecnológico](#️-stack-tecnológico)
- [Tecnologias Utilizadas](#️-tecnologias-utilizadas)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação](#-instalação)
- [Como Usar](#-como-usar)
- [Funcionalidades](#-funcionalidades)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Configuração do Supabase](#-configuração-do-supabase)
- [Contribuindo](#-contribuindo)
- [Troubleshooting](#-troubleshooting)
- [Licença](#-licença)

## ✨ Características

- ⚡ **Gerenciamento em Tempo Real** - Atualizações instantâneas do placar e estatísticas
- 📱 **Design Responsivo** - Funciona perfeitamente em desktop, tablet e celular
- 🎨 **Interface Dark Mode** - Tema escuro moderno e agradável aos olhos
- ⚖️ **Sorteio Inteligente** - Distribuição automática de times baseada no nível de habilidade (1 a 5 ⭐)
- 📅 **Agenda Automática** - Geração de partidas no formato Round-Robin (todos contra todos)
- 🏆 **Classificação Dinâmica** - Tabela atualizada em tempo real com saldo de pontos e aproveitamento
- 👑 **Finais e Pódio** - Chaveamento automático dos melhores colocados e tela de premiação
- 📊 **Estatísticas Detalhadas** - Rastreamento de pontuação, sets e performance
- 🖨️ **Exportar para PDF** - Gere relatórios das partidas em PDF
- 💾 **Sincronização na Nuvem** - Dados salvos automaticamente via Supabase
- 🔄 **Sincronização em Tempo Real** - Múltiplos dispositivos sincronizados
- 🎯 **Interface Intuitiva** - Fácil de usar, sem necessidade de treinamento

## 🛠️ Stack Tecnológico

| Tecnologia | Uso |
|---|---|
| **HTML5** | Estrutura e marcação semântica |
| **CSS3** | Estilização com variáveis CSS e Grid/Flexbox |
| **JavaScript Vanilla** | Lógica da aplicação e interatividade |
| **Supabase** | Backend e banco de dados em tempo real |
| **html2canvas** | Captura e renderização de elementos DOM |
| **html2pdf.js** | Geração de documentos PDF |
| **Google Fonts** | Tipografia (Inter) |

## 🛠️ Tecnologias Utilizadas

<p align="left">
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/html5/html5-original.svg" alt="HTML5" width="50" height="50"/>
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/css3/css3-original.svg" alt="CSS3" width="50" height="50"/>
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/javascript/javascript-original.svg" alt="JavaScript" width="50" height="50"/>
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/supabase/supabase-original.svg" alt="Supabase" width="50" height="50"/>
</p>

## 📦 Pré-requisitos

- Navegador web moderno (Chrome 90+, Firefox 88+, Safari 14+, Edge 90+)
- Conexão com a internet (para sincronização em nuvem)
- Projeto no [Supabase](https://supabase.com) configurado conforme a seção abaixo (necessário para login, persistência e sincronização)

## 🚀 Instalação

### Opção 1: Instalação Local Simples

```bash
# 1. Clone o repositório
git clone https://github.com/jppaztech/crieseuvolei.git
cd crieseuvolei

# 2. Abra o arquivo index.html em seu navegador
# No macOS:
open index.html

# No Linux:
xdg-open index.html

# No Windows:
start index.html
```

### Opção 2: Com Servidor Local (Recomendado)

```bash
# Usando Python 3
python3 -m http.server 8000

# Usando Node.js (http-server)
npx http-server

# Usando PHP
php -S localhost:8000
```

Depois acesse: `http://localhost:8000`

### Opção 3: Deploy na Nuvem

#### Vercel
```bash
npm install -g vercel
vercel
```

#### Netlify
```bash
npm install -g netlify-cli
netlify deploy
```

#### GitHub Pages
O projeto pode ser publicado pelo GitHub Pages após habilitar a opção **Settings >
Pages** e selecionar a branch e a pasta de publicação. O endereço final depende da
configuração do repositório; ele não é criado automaticamente apenas por clonar o projeto.

## 📖 Como Usar

### Início Rápido

1. **Acesse a aplicação** em seu navegador
2. **Crie uma nova partida** preenchendo os dados dos times
3. **Atualize o placar** usando os botões de incremento/decremento
4. **Acompanhe em tempo real** em múltiplos dispositivos
5. **Exporte o resultado** como PDF quando a partida terminar

### Interface Principal

```
┌─────────────────────────────────────────┐
│  🏐 Peladas de Vôlei - Ao Vivo          │
├─────────────────────────────────────────┤
│                                         │
│  [ 1) Cadastro ]  [ 2) Rodadas ]        │
│  [ 3) Finais   ]  [ 4) Pódio   ]        │
│                                         │
│  ┌─ Cadastro e Sorteio ──────────────┐  │
│  │ • Defina Jogadores, Times e Rods. │  │
│  │ • Dê notas de Habilidade (1 a 5⭐)│  │
│  │ • Sorteio Equilibrado Automático  │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌─ Painel de Jogo (Ao Vivo) ────────┐  │
│  │ • Placar dinâmico (+ e -)         │  │
│  │ • Classificação c/ Saldo de Pts   │  │
│  │ • Agenda Completa e Finais        │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## 🎯 Funcionalidades

### Gerenciamento de Torneio e Placar
- ✅ Sorteio equilibrado de jogadores (por estrelas)
- ✅ Geração automática de rodadas (todos contra todos)
- ✅ Incrementar/decrementar pontos ao vivo
- ✅ Tabela de classificação com saldo de pontos
- ✅ Chaveamento automático para Finais e 3º lugar

### Dados e Estatísticas
- ⚠️ O placar atual registra o resultado final da partida; pontuação por set ainda está planejada
- ✅ Acompanhar performance em tempo real
- ✅ Comparação entre times

### Exportação
- ✅ Gerar PDF com resultado final
- ✅ Incluir data, hora e local
- ✅ Capturar layout completo

### Sincronização
- ✅ Salvar dados na nuvem (Supabase)
- ✅ Sincronizar entre dispositivos
- ⚠️ O histórico de torneios ainda está planejado; o estado atual usa uma partida compartilhada

## 📁 Estrutura do Projeto

```
crieseuvolei/
├── index.html          # Arquivo principal (HTML + CSS + JS)
├── README.md           # Este arquivo
└── LICENSE             # Licença MIT
```

## ⚙️ Configuração do Supabase

### 1. Criar Projeto no Supabase

```bash
# Visite https://supabase.com
# Crie um novo projeto
# Copie as credenciais do projeto
```

### 2. Configurar as credenciais

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

Use o schema multi-torneio abaixo para permitir que várias pessoas criem e gerenciem seus torneios em paralelo:

```sql
-- Torneios independentes por usuário / grupo
CREATE TABLE tournaments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  owner_email TEXT NOT NULL,
  scorer_emails TEXT[] NOT NULL DEFAULT '{}',
  game_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Mantém compatibilidade com o modelo antigo, caso alguma instalação ainda use app_state
CREATE TABLE app_state (
  id INTEGER PRIMARY KEY,
  game_data JSONB NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_state ENABLE ROW LEVEL SECURITY;

-- Exemplo de política mínima: leitura pública para estado compartilhado, mas a regra final deve ser reforçada
-- com RLS por usuário/torneio quando a aplicação passar a ter autenticação de produção em escala real.
CREATE POLICY "Leitura pública dos torneios"
  ON tournaments FOR SELECT USING (true);

CREATE POLICY "Autenticado pode gravar torneios"
  ON tournaments FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Autenticado pode atualizar torneios"
  ON tournaments FOR UPDATE USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Autenticado pode deletar torneios"
  ON tournaments FOR DELETE USING (auth.role() = 'authenticated');

CREATE POLICY "Leitura pública do estado legado"
  ON app_state FOR SELECT USING (true);

CREATE POLICY "Admin autenticado pode gravar estado legado"
  ON app_state FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- No painel do Supabase, adicione tournaments e app_state à publicação supabase_realtime.
```

Crie pelo menos um usuário em **Authentication > Users** para o login administrativo.
O primeiro carregamento pode mostrar um aviso se a tabela, as políticas ou o Realtime
estiverem incompletos.

### 4. Configuração do deploy em Netlify / Vercel

Para uso real em produção, configure as variáveis de ambiente do deploy e mantenha apenas
os valores públicos do cliente (URL e chave publishable do Supabase):

```bash
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_KEY=sua-chave-publishable
```

No Netlify ou Vercel, mantenha isso em **Environment variables**; nunca exponha uma
`service_role` ou segredo no HTML. Essa aplicação é um front-end estático e depende dos
controles de acesso e RLS do banco para manter o ambiente seguro.

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
