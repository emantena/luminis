const crypto = require('crypto');

/**
 * Gera um traceId no formato W3C traceparent (00-<trace>-<span>-01), alinhado
 * ao exemplo de docs/architecture/backend-contracts.md ("00-...").
 */
function generateTraceId() {
  const traceId = crypto.randomBytes(16).toString('hex');
  const spanId = crypto.randomBytes(8).toString('hex');
  return `00-${traceId}-${spanId}-01`;
}

/**
 * Monta o envelope de erro padrao do Luminis: code, message, traceId, errors.
 * `errors` e `null` quando o erro nao tiver detalhamento por campo.
 */
function buildErrorBody(code, message, traceId, errors = null) {
  return { code, message, traceId, errors };
}

/**
 * Envia uma resposta de erro usando o envelope padrao. Reaproveita o traceId
 * ja atribuido a requisicao (res.locals.traceId) quando existir.
 */
function sendError(req, res, status, code, message, errors = null) {
  const traceId = res.locals.traceId || generateTraceId();
  res.status(status).json(buildErrorBody(code, message, traceId, errors));
}

module.exports = { generateTraceId, buildErrorBody, sendError };
