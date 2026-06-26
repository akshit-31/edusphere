const http = require('https');

function checkUrl(url) {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          body: data.substring(0, 500)
        });
      });
    }).on('error', (err) => {
      reject(err);
    });
  });
}

async function main() {
  const urls = [
    'https://edusphere-erp-frontend.onrender.com/api/v1/health',
    'https://edusphere-backend.onrender.com/api/v1/health',
    'https://edusphere-erp-frontend.onrender.com/health',
    'https://edusphere-backend.onrender.com/health'
  ];

  for (const url of urls) {
    try {
      console.log(`Checking ${url}...`);
      const res = await checkUrl(url);
      console.log(`Result: Status ${res.statusCode}, Body: ${res.body}`);
    } catch (err) {
      console.log(`Error checking ${url}: ${err.message}`);
    }
  }
}

main();
