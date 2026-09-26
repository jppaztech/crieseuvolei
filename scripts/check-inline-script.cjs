const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { spawnSync } = require('node:child_process');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');
const scripts = [...html.matchAll(/<script(?:\s[^>]*)?>([\s\S]*?)<\/script>/gi)]
  .map((match) => match[1].trim())
  .filter(Boolean);

if (scripts.length !== 1) {
  throw new Error(`Esperado 1 script inline da aplicação; encontrados ${scripts.length}.`);
}

new vm.Script(scripts[0], { filename: 'index.html:inline-script' });
new vm.Script(fs.readFileSync(path.join(__dirname, '..', 'service-worker.js'), 'utf8'), { filename: 'service-worker.js' });
JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'manifest.webmanifest'), 'utf8'));
JSON.parse(fs.readFileSync(path.join(__dirname, '..', '.impeccable', 'design.json'), 'utf8'));

const schema = fs.readFileSync(path.join(__dirname, '..', 'supabase', 'schema.sql'), 'utf8');
const netlify = fs.readFileSync(path.join(__dirname, '..', 'netlify.toml'), 'utf8');
for (const setting of ['SUPABASE_URL', 'SUPABASE_PUBLISHABLE_KEY', 'APP_BASE_URL', 'APP_LANGUAGE_DEFAULT']) {
  if (!new RegExp(`^\\s*${setting}\\s*=`, 'm').test(netlify)) {
    throw new Error(`Configuração Netlify ausente: ${setting}.`);
  }
}
for (const table of ['profiles', 'tournaments', 'tournament_members', 'tournament_invites']) {
  if (!new RegExp(`ALTER TABLE public\\.${table} ENABLE ROW LEVEL SECURITY`, 'i').test(schema)) {
    throw new Error(`RLS não está habilitada para public.${table}.`);
  }
}
for (const required of [
  "status = 'live'",
  "owner_id = auth.uid()",
  "public.is_tournament_editor(id)",
  'lower(ti.invited_email) = v_email',
  "ti.status = 'pending'",
  'CREATE POLICY tournaments_insert_owner',
  'CREATE POLICY tournament_invites_read_invitee_or_editors',
  'CREATE OR REPLACE FUNCTION public.accept_tournament_invite',
  'CREATE OR REPLACE FUNCTION public.create_tournament_invite',
  'ALTER TABLE public.app_state ENABLE ROW LEVEL SECURITY'
]) {
  if (!schema.includes(required)) throw new Error(`Verificação do schema ausente: ${required}.`);
}
if (/CREATE POLICY\s+\S+\s+ON public\.tournament_members\s+FOR ALL/i.test(schema)) {
  throw new Error('Política ampla de escrita encontrada em tournament_members.');
}
const secretProbe = spawnSync(process.execPath, [path.join(__dirname, 'generate-config.cjs')], {
  encoding: 'utf8',
  env: {
    ...process.env,
    CONTEXT: 'production',
    SUPABASE_URL: 'https://test-project.supabase.co',
    SUPABASE_PUBLISHABLE_KEY: 'sb_secret_test_value'
  }
});
if (secretProbe.status === 0 || !`${secretProbe.stdout}\n${secretProbe.stderr}`.includes('service_role')) {
  throw new Error('O build deve bloquear chaves secret/service_role.');
}

const dictionaryMatch = scripts[0].match(/const translations = (\{[\s\S]*?^\s{6}\})\s*;/m);
if (!dictionaryMatch) throw new Error('Dicionário de traduções não encontrado.');
const dictionaries = vm.runInNewContext(`(${dictionaryMatch[1]})`);
const definedKeys = new Set(Object.keys(dictionaries['pt-BR']));
const translatedKeys = new Set(Object.keys(dictionaries['en-US']));
const references = new Set([
  ...[...html.matchAll(/data-i18n(?:-placeholder|-aria)?="([^"]+)"/g)].map((match) => match[1]),
  ...[...scripts[0].matchAll(/\btr\('([^']+)'\)/g)].map((match) => match[1])
]);
const missing = [...references].filter((key) => !definedKeys.has(key) || !translatedKeys.has(key));
if (missing.length) throw new Error(`Chaves sem tradução PT-BR/EN-US: ${missing.join(', ')}`);
console.log('JavaScript, PWA, traduções, configurações e contratos RLS/convites válidos.');
