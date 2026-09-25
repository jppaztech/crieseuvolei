const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

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
console.log('JavaScript, manifesto, tokens de design e chaves PT-BR/EN-US válidos.');
