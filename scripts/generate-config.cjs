const fs = require('node:fs');
const path = require('node:path');

const supabaseUrl = process.env.SUPABASE_URL || '';
const supabaseKey = process.env.SUPABASE_PUBLISHABLE_KEY || process.env.SUPABASE_KEY || '';
const appBaseUrl = process.env.APP_BASE_URL || '';
const defaultLanguage = process.env.APP_LANGUAGE_DEFAULT === 'en-US' ? 'en-US' : 'pt-BR';

function isServiceRoleKey(key) {
  if (key.startsWith('sb_secret_')) return true;
  const parts = key.split('.');
  if (parts.length !== 3) return false;
  try {
    const payload = JSON.parse(Buffer.from(parts[1], 'base64url').toString('utf8'));
    return payload.role === 'service_role';
  } catch {
    return false;
  }
}

if (process.env.CONTEXT === 'production' && (!supabaseUrl || !supabaseKey)) {
  throw new Error('Defina SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY (ou SUPABASE_KEY) nas variáveis de produção do Netlify.');
}
if (supabaseKey && isServiceRoleKey(supabaseKey)) {
  throw new Error('Chave secret/service_role bloqueada: a aplicação web aceita somente a chave publishable/anon.');
}

if (supabaseUrl && !/^https:\/\/[^/]+\.supabase\.co\/?$/.test(supabaseUrl)) {
  throw new Error('SUPABASE_URL deve ser a URL HTTPS do projeto Supabase.');
}

const output = `window.APP_CONFIG = Object.freeze(${JSON.stringify({
  supabaseUrl: supabaseUrl.replace(/\/$/, ''),
  supabaseKey,
  appBaseUrl: appBaseUrl.replace(/\/$/, ''),
  defaultLanguage
})});\n`;

fs.writeFileSync(path.join(__dirname, '..', 'runtime-config.js'), output, { encoding: 'utf8' });
console.log('Configuração pública da aplicação gerada.');
