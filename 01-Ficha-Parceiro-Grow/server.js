const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');

const PORT = 8080;
const SANKHYA_HOST = 'sistema.motoarte.com';
const SANKHYA_BASE = '/mge/service.sbr';

// Armazena o cookie de sessão do Sankhya no servidor (resolve problema de domínio)
let sankhyaSessionCookie = null;

// MIME types para servir arquivos estáticos
const MIME_TYPES = {
    '.html': 'text/html; charset=utf-8',
    '.css': 'text/css; charset=utf-8',
    '.js': 'application/javascript; charset=utf-8',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon'
};

const server = http.createServer((req, res) => {

    // ---- PROXY: requisições para /api/* são encaminhadas ao Sankhya ----
    if (req.url.startsWith('/api/')) {

        // Responde preflight CORS imediatamente
        if (req.method === 'OPTIONS') {
            res.setHeader('Access-Control-Allow-Origin', '*');
            res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
            res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
            res.writeHead(204);
            res.end();
            return;
        }

        // Remove o prefixo /api e monta a URL de destino
        const apiPath = req.url.replace('/api/', '').replace('/api', '');
        const targetPath = SANKHYA_BASE + (apiPath.startsWith('?') ? '' : '/') + apiPath;

        console.log(`[PROXY] ${req.method} ${targetPath}`);

        // Coleta o body da requisição
        let body = '';
        req.on('data', chunk => { body += chunk; });
        req.on('end', () => {

            const options = {
                hostname: SANKHYA_HOST,
                port: 443,
                path: targetPath,
                method: req.method,
                headers: {
                    'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:28.0) Gecko/20100101 Firefox/28.0'
                },
                rejectUnauthorized: false
            };

            // Repassa Content-Type do request original
            if (req.headers['content-type']) {
                options.headers['Content-Type'] = req.headers['content-type'];
            }

            // Usa o cookie de sessão armazenado no servidor
            if (sankhyaSessionCookie) {
                options.headers['Cookie'] = sankhyaSessionCookie;
                console.log('[PROXY] Enviando cookie:', sankhyaSessionCookie);
            }

            const proxyReq = https.request(options, (proxyRes) => {
                // Headers CORS
                res.setHeader('Access-Control-Allow-Origin', '*');
                res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
                res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

                // Captura e armazena Set-Cookie do Sankhya no servidor
                const setCookie = proxyRes.headers['set-cookie'];
                if (setCookie) {
                    setCookie.forEach(c => {
                        const cookieValue = c.split(';')[0]; // Pega só o nome=valor
                        sankhyaSessionCookie = cookieValue;
                        console.log('[PROXY] Cookie de sessão salvo:', cookieValue);
                    });
                }

                // Coleta response body para log
                let responseBody = '';
                proxyRes.on('data', chunk => {
                    responseBody += chunk;
                    res.write(chunk);
                });
                proxyRes.on('end', () => {
                    console.log(`[PROXY] Resposta ${proxyRes.statusCode}: ${responseBody.substring(0, 200)}...`);
                    res.end();
                });

                res.writeHead(proxyRes.statusCode, proxyRes.statusMessage);
            });

            proxyReq.on('error', (err) => {
                console.error('[PROXY ERROR]', err.message);
                res.writeHead(502, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'Proxy error', message: err.message }));
            });

            if (body) {
                proxyReq.write(body);
            }
            proxyReq.end();
        });

        return;
    }

    // ---- STATIC FILES: serve os arquivos do projeto ----
    let filePath = req.url === '/' ? '/index.html' : req.url;
    filePath = path.join(__dirname, filePath);

    const ext = path.extname(filePath);
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    fs.readFile(filePath, (err, content) => {
        if (err) {
            if (err.code === 'ENOENT') {
                res.writeHead(404);
                res.end('404 - Not Found');
            } else {
                res.writeHead(500);
                res.end('500 - Server Error');
            }
            return;
        }

        res.writeHead(200, { 'Content-Type': contentType });
        res.end(content);
    });
});

server.listen(PORT, () => {
    console.log('');
    console.log('  ╔══════════════════════════════════════════╗');
    console.log('  ║          🌱 GROW - Proxy Server          ║');
    console.log('  ╠══════════════════════════════════════════╣');
    console.log(`  ║  Local:  http://localhost:${PORT}            ║`);
    console.log(`  ║  Proxy:  /api/* → ${SANKHYA_HOST}  ║`);
    console.log('  ╚══════════════════════════════════════════╝');
    console.log('');
});
