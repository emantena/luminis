const http = require('node:http');
const path = require('node:path');
const { spawn } = require('node:child_process');

const port = Number(process.env.MOCK_API_PORT || 3000);
const healthPath = '/api/health';
const legacyReadinessPath = '/api/f5-readiness-check';

function request(pathname) {
  return new Promise((resolve, reject) => {
    const request = http.get(
      {
        hostname: '127.0.0.1',
        port,
        path: pathname,
        timeout: 1500,
      },
      (response) => {
        let body = '';
        response.setEncoding('utf8');
        response.on('data', (chunk) => {
          body += chunk;
        });
        response.on('end', () => resolve({ statusCode: response.statusCode, body }));
      },
    );

    request.on('timeout', () => request.destroy(new Error('Timeout ao verificar mock API.')));
    request.on('error', reject);
  });
}

async function isLuminisMockApi() {
  const health = await request(healthPath);
  if (health.statusCode === 200) {
    try {
      return JSON.parse(health.body).service === 'luminis-mock-api';
    } catch {
      return false;
    }
  }

  // Compatibilidade com uma instância iniciada antes da rota de health existir.
  const legacy = await request(legacyReadinessPath);
  if (legacy.statusCode !== 404) return false;

  try {
    return JSON.parse(legacy.body).code === 'mock_api.route_not_found';
  } catch {
    return false;
  }
}

async function main() {
  try {
    if (await isLuminisMockApi()) {
      console.log(`Luminis mock-api rodando em http://localhost:${port} (instância reutilizada)`);
      return;
    }

    throw new Error(`A porta ${port} já está em uso por outro serviço.`);
  } catch (error) {
    if (error.code !== 'ECONNREFUSED') {
      throw error;
    }
  }

  const server = spawn(process.execPath, [path.join(__dirname, '..', 'server.js')], {
    env: process.env,
    stdio: 'inherit',
  });

  server.on('error', (error) => {
    console.error(error);
    process.exitCode = 1;
  });
  server.on('exit', (code) => {
    process.exitCode = code ?? 1;
  });
}

main().catch((error) => {
  console.error(`Não foi possível preparar o mock API: ${error.message}`);
  process.exitCode = 1;
});
