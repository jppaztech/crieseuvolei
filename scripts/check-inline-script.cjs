const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
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
new vm.Script(fs.readFileSync(path.join(__dirname, '..', 'assets', 'tournament-engine.js'), 'utf8'), { filename: 'assets/tournament-engine.js' });
new vm.Script(fs.readFileSync(path.join(__dirname, '..', 'assets', 'report-exporter.js'), 'utf8'), { filename: 'assets/report-exporter.js' });
JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'manifest.webmanifest'), 'utf8'));
JSON.parse(fs.readFileSync(path.join(__dirname, '..', '.impeccable', 'design.json'), 'utf8'));

const schema = fs.readFileSync(path.join(__dirname, '..', 'supabase', 'schema.sql'), 'utf8');
const inviteMigration = fs.readFileSync(path.join(__dirname, '..', 'supabase', 'migrations', '20260925220000_convites_tokenizados_uso_unico.sql'), 'utf8');
const netlify = fs.readFileSync(path.join(__dirname, '..', 'netlify.toml'), 'utf8');
const serviceWorker = fs.readFileSync(path.join(__dirname, '..', 'service-worker.js'), 'utf8');
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
  'invite_token TEXT',
  'expires_at TIMESTAMPTZ',
  'ti.invite_token = p_invite_token',
  "SET status = 'accepted', invite_token = NULL",
  'ALTER TABLE public.app_state ENABLE ROW LEVEL SECURITY'
]) {
  if (!schema.includes(required)) throw new Error(`Verificação do schema ausente: ${required}.`);
}
const inviteReadGrant = schema.match(/GRANT SELECT \(([^)]*)\)\s+ON public\.tournament_invites TO authenticated/i);
if (!inviteReadGrant || inviteReadGrant[1].includes('invite_token')) {
  throw new Error('O token secreto do convite não pode ser lido pela API do navegador.');
}
for (const required of [
  'DROP FUNCTION IF EXISTS public.create_tournament_invite(UUID, TEXT, TEXT)',
  'DROP FUNCTION IF EXISTS public.accept_tournament_invite(UUID)',
  'p_invite_token TEXT',
  "NOW() + INTERVAL '30 days'",
  "SET status = 'expired'",
  "SET status = 'accepted', invite_token = NULL",
  'GRANT EXECUTE ON FUNCTION public.accept_tournament_invite(TEXT) TO authenticated'
]) {
  if (!inviteMigration.includes(required)) throw new Error(`Verificação da migração de convite ausente: ${required}.`);
}
for (const asset of ['/assets/tournament-engine.js', '/assets/report-exporter.js']) {
  if (!serviceWorker.includes(asset)) throw new Error(`Módulo ausente do shell offline: ${asset}.`);
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
for (const status of ['pending', 'accepted', 'rejected', 'expired']) {
  if (!definedKeys.has(status) || !translatedKeys.has(status)) {
    throw new Error(`Status de convite sem tradução PT-BR/EN-US: ${status}.`);
  }
}

const engineContext = { window: {} };
vm.runInNewContext(fs.readFileSync(path.join(__dirname, '..', 'assets', 'tournament-engine.js'), 'utf8'), engineContext);
const engine = engineContext.window.CrieSeuVoleiTournament;
const teams = engine.balanceTeams(
  Array.from({ length: 12 }, (_, index) => ({ name: `Jogador ${index + 1}`, skill: (index % 5) + 1 })),
  ['Águias', 'Ondas', 'Areia', 'Rede']
);
assert.deepEqual([...teams].map((team) => team.members.length), [3, 3, 3, 3]);
const heavilySkewedTeams = engine.balanceTeams(
  Array.from({ length: 8 }, (_, index) => ({ name: `Atleta ${index + 1}`, skill: index < 4 ? 5 : 1 })),
  ['A', 'B', 'C', 'D']
);
assert.deepEqual([...heavilySkewedTeams].map((team) => team.members.length), [2, 2, 2, 2]);
assert.equal([...heavilySkewedTeams].map((team) => team.members.reduce((sum, player) => sum + player.skill, 0)).join(','), '6,6,6,6');
const schedule = engine.createRoundRobinSchedule(4, 3);
assert.equal(schedule.length, 6);
assert.equal(new Set(schedule.map((match) => [match.a, match.b].sort().join('-')).size), 6);
assert.equal(engine.validateScore(21, 19), true);
assert.equal(engine.validateScore(21, 21), false);
assert.equal(engine.normalize({ schedule: [{ a: 0, b: 1, scoreA: 21, scoreB: 21 }] }).schedule[0].status, 'pending');
const standings = engine.calculateStandings(teams, schedule.map((match, index) => ({
  ...match, scoreA: index % 2 === 0 ? 21 : 18, scoreB: index % 2 === 0 ? 18 : 21, status: 'done'
})));
const semifinals = engine.createSemifinals(standings);
assert.deepEqual([...semifinals].map((match) => [match.a, match.b]), [
  [standings[0].index, standings[3].index],
  [standings[1].index, standings[2].index]
]);
const completedSemifinals = semifinals.map((match) => ({ ...match, scoreA: 21, scoreB: 15, status: 'done' }));
const playoffs = engine.createPlacementMatches(completedSemifinals).map((match) => ({
  ...match, scoreA: 21, scoreB: 16, status: 'done'
}));
assert.equal(engine.getPodium(playoffs, standings).length, 4);
const reportContext = { window: {} };
vm.runInNewContext(fs.readFileSync(path.join(__dirname, '..', 'assets', 'report-exporter.js'), 'utf8'), reportContext);
const rosterMarkup = reportContext.window.CrieSeuVoleiReports.teamRosterHtml(
  [{ name: '<script>alert(1)</script>', members: [{ name: 'Jogadora', skill: 4 }] }],
  { teams: 'Times', skill: 'Nível' }
);
assert.equal(rosterMarkup.includes('<script>alert(1)</script>'), false);
console.log('JavaScript, regras de torneio, PWA, traduções, configurações e contratos RLS/convites válidos.');
