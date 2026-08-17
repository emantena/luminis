const fs = require('fs');
const path = require('path');

const DB_PATH = path.join(__dirname, '..', 'db.json');
const GOOGLE_TOKENS_PATH = path.join(__dirname, '..', 'fixtures', 'google-tokens.json');

const seed = JSON.parse(fs.readFileSync(DB_PATH, 'utf-8'));
const googleTokens = JSON.parse(fs.readFileSync(GOOGLE_TOKENS_PATH, 'utf-8'));

/**
 * Estado em memoria do mock-api (ADR-009: "dados permanecem em memoria
 * durante a execucao local"). Clonado a partir de db.json/fixtures no boot;
 * mutacoes de runtime (registro, tentativas de login, tokens emitidos) nao
 * sao gravadas de volta nos arquivos. Reiniciar o processo restaura o
 * estado inicial dos cenarios.
 */
const state = {
  users: structuredClone(seed.users),
  passwordCredentials: structuredClone(seed.passwordCredentials),
  externalLogins: structuredClone(seed.externalLogins),
  catalogBooks: structuredClone(seed.catalogBooks || []),
  bookDrafts: structuredClone(seed.bookDrafts || []),
  bookshelfItems: structuredClone(seed.bookshelfItems || []),
  readingSessions: structuredClone(seed.readingSessions || []),
  readingProgressEntries: structuredClone(seed.readingProgressEntries || []),
  readingPlans: structuredClone(seed.readingPlans || []),
  readingGoals: structuredClone(seed.readingGoals || []),
  googleTokens: structuredClone(googleTokens),
  accessTokens: new Map(),
  refreshTokens: new Map(),
  passwordResetTokens: new Map(),
};

module.exports = state;
