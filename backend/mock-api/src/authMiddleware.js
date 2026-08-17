const state = require('./state');
const { sendError } = require('./errors');

/**
 * Middleware de autenticacao mockada. Exige `Authorization: Bearer <token>`
 * emitido por login/registro/google e anexa `req.currentUserId` quando
 * valido. Nao substitui autorizacao real de backend; existe apenas para
 * exercitar o fluxo protegido do prototipo (ADR-009).
 */
function requireAuth(req, res, next) {
  const header = req.headers['authorization'] || '';
  const [scheme, token] = header.split(' ');

  if (scheme !== 'Bearer' || !token) {
    return sendError(req, res, 401, 'auth.unauthorized', 'Autenticacao necessaria.');
  }

  const session = state.accessTokens.get(token);
  if (!session || session.expiresAt < Date.now()) {
    return sendError(req, res, 401, 'auth.unauthorized', 'Sessao invalida ou expirada.');
  }

  req.currentUserId = session.userId;
  next();
}

module.exports = { requireAuth };
