const https = require('https');

async function testLogin(email, password) {
  const loginData = JSON.stringify({ email, password });
  const loginOptions = {
    hostname: 'edusphere-erp-frontend.onrender.com',
    port: 443,
    path: '/api/v1/auth/login',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': loginData.length
    }
  };

  return new Promise((resolve) => {
    const req = https.request(loginOptions, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(body);
          resolve({ status: res.statusCode, data: json });
        } catch (_) {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });
    req.write(loginData);
    req.end();
  });
}

async function main() {
  // Test combinations
  const res1 = await testLogin('edusphereteacher@gmail.com', 'edusphere');
  console.log("edusphereteacher@gmail.com / edusphere:", res1.status, JSON.stringify(res1.data));

  const res2 = await testLogin('edusphereteacher@gmail.com', 'Teacher@2024');
  console.log("edusphereteacher@gmail.com / Teacher@2024:", res2.status, JSON.stringify(res2.data));

  const res3 = await testLogin('priya.joshi@edusphere.edu', 'edusphere');
  console.log("priya.joshi@edusphere.edu / edusphere:", res3.status, JSON.stringify(res3.data));
}

main();
