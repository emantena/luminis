const jsonServer = require('json-server');

const { generateTraceId } = require('./src/errors');
const authRouter = require('./src/routes/auth');
const catalogRouter = require('./src/routes/catalog');
const bookshelfRouter = require('./src/routes/bookshelf');
const readingRouter = require('./src/routes/reading');
const goalsRouter = require('./src/routes/goals');

const PORT = process.env.MOCK_API_PORT || 3000;

const server = jsonServer.create();
const middlewares = jsonServer.defaults();

server.use(middlewares);
server.use(jsonServer.bodyParser);

// Atribui um traceId por requisicao, reaproveitado pelo envelope de erro
// padrao (code/message/traceId/errors) definido em backend-contracts.md.
server.use((req, res, next) => {
  res.locals.traceId = generateTraceId();
  res.setHeader('x-trace-id', res.locals.traceId);
  next();
});

// Endpoint operacional para a ferramenta local confirmar que a porta 3000
// pertence ao mock do Luminis antes de reutilizar o processo no F5.
server.get('/api/health', (_req, res) => {
  res.status(200).json({
    service: 'luminis-mock-api',
    status: 'ok',
  });
});

// Rotas simuladas por módulo, todas atrás da fronteira /api. Os routers
// encapsulam as regras de contrato; json-server não é exposto ao Flutter.
server.use('/api', authRouter);
server.use('/api', catalogRouter);
server.use('/api', bookshelfRouter);
server.use('/api', readingRouter);
server.use('/api', goalsRouter);

// Qualquer rota fora do contrato simulado ate agora. Este codigo e um
// detalhe interno do mock-api, nao um codigo de erro aprovado do backend.
server.use((req, res) => {
  res.status(404).json({
    code: 'mock_api.route_not_found',
    message: 'Rota nao implementada no mock-api.',
    traceId: res.locals.traceId || generateTraceId(),
    errors: null,
  });
});

if (require.main === module) {
  server.listen(PORT, () => {
    console.log(`Luminis mock-api rodando em http://localhost:${PORT}`);
  });
}

module.exports = server;
