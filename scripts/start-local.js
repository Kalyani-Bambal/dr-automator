const { spawn } = require('child_process');
const net = require('net');

function isPortFree(port) {
  return new Promise((resolve) => {
    const server = net.createServer();
    server.unref();
    server.on('error', () => resolve(false));
    server.listen(port, '0.0.0.0', () => {
      server.close(() => resolve(true));
    });
  });
}

async function getFreePort(startPort, count = 20) {
  for (let port = startPort; port < startPort + count; port += 1) {
    if (await isPortFree(port)) {
      return String(port);
    }
  }

  throw new Error(`No free ports found in range ${startPort}-${startPort + count - 1}`);
}

function run(command, args, env = {}) {
  return spawn(command, args, {
    stdio: 'inherit',
    shell: true,
    env: { ...process.env, ...env },
  });
}

(async () => {
  const devMode = process.argv.includes('--dev');
  const backendPort = process.env.BACKEND_PORT || await getFreePort(5000);
  const frontendPort = process.env.FRONTEND_PORT || await getFreePort(3000);

  console.log(`Using backend port ${backendPort} and frontend port ${frontendPort}`);

  const backend = run('npm', ['--prefix', 'backend', devMode ? 'run' : 'run', devMode ? 'dev' : 'start'], {
    DB_HOST: 'localhost',
    DB_PORT: '3306',
    DB_USER: 'root',
    DB_PASSWORD: 'rootpassword',
    DB_NAME: 'drapp',
    PORT: backendPort,
  });

  const frontend = run('npm', ['--prefix', 'frontend', devMode ? 'run' : 'run', devMode ? 'dev' : 'start'], {
    NEXT_PUBLIC_API_URL: `http://localhost:${backendPort}`,
    PORT: frontendPort,
  });

  backend.on('exit', (code) => {
    if (code !== 0) {
      console.error('Backend exited unexpectedly');
      frontend.kill('SIGTERM');
      process.exit(code || 1);
    }
  });

  frontend.on('exit', (code) => {
    if (code !== 0) {
      console.error('Frontend exited unexpectedly');
      backend.kill('SIGTERM');
      process.exit(code || 1);
    }
  });

  process.on('SIGINT', () => {
    backend.kill('SIGINT');
    frontend.kill('SIGINT');
    process.exit(0);
  });
})();
