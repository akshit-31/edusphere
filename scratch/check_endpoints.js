const http = require('https');

function check(url) {
    return new Promise((resolve) => {
        console.log(`Checking ${url}...`);
        const req = http.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                console.log(`[${res.statusCode}] ${url}`);
                console.log("Response:", body.substring(0, 300));
                resolve(body);
            });
        });
        req.on('error', (err) => {
            console.log(`Error on ${url}:`, err.message);
            resolve(null);
        });
    });
}

async function main() {
    await check("https://edusphere-erp-frontend.onrender.com/api/v1/health");
    await check("https://edusphere-erp-latest-xffb.onrender.com/api/v1/health");
}

main();
