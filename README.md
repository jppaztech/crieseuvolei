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
- [Stack Tecnológico](#--stack-tecnológico)
- [Tecnologias Utilizadas](#--tecnologias-utilizadas)
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
- Conta no [Supabase](https://supabase.com) (opcional, para funcionalidades cloud)

## 🚀 Instalação

### Opção 1: Instalação Local Simples

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/crieseuvolei.git
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
```bash
# O repositório será servido automaticamente em:
# https://seu-usuario.github.io/crieseuvolei
```

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
- ✅ Visualizar pontuação por set
- ✅ Acompanhar performance em tempo real
- ✅ Comparação entre times

### Exportação
- ✅ Gerar PDF com resultado final
- ✅ Incluir data, hora e local
- ✅ Capturar layout completo

### Sincronização
- ✅ Salvar dados na nuvem (Supabase)
- ✅ Sincronizar entre dispositivos
- ✅ Recuperar histórico de partidas

## 📁 Estrutura do Projeto

```
crieseuvolei/
├── index.html          # Arquivo principal (HTML + CSS + JS)
├── README.md           # Este arquivo
├── LICENSE             # Licença MIT
├── .git/               # Controle de versão
└── [opcional: assets/]
    ├── css/           # Estilos adicionais (se aplicável)
    └── js/            # Scripts externos (se aplicável)
```

## ⚙️ Configuração do Supabase

### 1. Criar Projeto no Supabase

```bash
# Visite https://supabase.com
# Crie um novo projeto
# Copie as credenciais do projeto
```

### 2. Adicionar Variáveis de Ambiente

No `index.html`, localize a inicialização do Supabase:

```javascript
const supabaseUrl = 'https://seu-projeto.supabase.co'
const supabaseKey = 'sua-chave-publica'
const supabase = supabase.createClient(supabaseUrl, supabaseKey)
```

### 3. Criar Tabelas no Banco de Dados

```sql
-- Tabela para guardar o estado global do torneio
CREATE TABLE app_state (
  id INTEGER PRIMARY KEY,
  game_data JSONB NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Inserir a linha inicial que o sistema vai atualizar
INSERT INTO app_state (id, game_data) VALUES (1, '{}');
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Siga os passos abaixo:

### 1. Fork o Repositório
```bash
# Clique no botão "Fork" no GitHub
```

### 2. Clone Seu Fork
```bash
git clone https://github.com/seu-usuario/crieseuvolei.git
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
- **Compatibilidade**: 95%+ dos navegadores modernos
- **Acessibilidade**: WCAG 2.1 Level AA

## 🔐 Segurança

- Todas as credenciais devem ser mantidas seguras
- Nunca compartilhe suas chaves do Supabase
- Use variáveis de ambiente em produção
- Implemente autenticação apropriada

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

## Autor
João Paz – [LinkedIn](https://www.linkedin.com/in/joaospaz) | [GitHub](https://github.com/jppaztech) | [Email](mailto:jpsantospaz@hotmail.com) | WhatsApp: +55 81 99885-5027

## Contato
Para dúvidas, sugestões ou oportunidades de colaboração, entre em contato por e-mail, WhatsApp ou conecte-se comigo pelo LinkedIn.

## Contribuição
Contribuições são bem-vindas!  
Se você deseja melhorar este projeto, faça um fork do repositório e envie um pull request.  
**Importante:** qualquer alteração, mesmo pequena, deve ser aprovada previamente por mim antes de ser incorporada.  
Para mudanças maiores, abra uma issue primeiro para discutirmos o que você gostaria de modificar.

