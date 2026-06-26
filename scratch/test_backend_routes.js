const http = require('https');

function postJson(url, body) {
  return new Promise((resolve, reject) => {
    const parsedUrl = new URL(url);
    const bodyStr = JSON.stringify(body);
    const options = {
      hostname: parsedUrl.hostname,
      port: 443,
      path: parsedUrl.pathname,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': bodyStr.length
      }
    };
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        resolve({ statusCode: res.statusCode, body: JSON.parse(data) });
      });
    });
    req.on('error', (err) => { reject(err); });
    req.write(bodyStr);
    req.end();
  });
}

function getJson(url, token) {
  return new Promise((resolve, reject) => {
    const parsedUrl = new URL(url);
    const options = {
      hostname: parsedUrl.hostname,
      port: 443,
      path: parsedUrl.pathname + parsedUrl.search,
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    };
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          resolve({ statusCode: res.statusCode, body: JSON.parse(data) });
        } catch(e) {
          resolve({ statusCode: res.statusCode, body: data });
        }
      });
    });
    req.on('error', (err) => { reject(err); });
    req.end();
  });
}

async function main() {
  const baseUrl = 'https://edusphere-erp-frontend.onrender.com/api/v1';
  
  // Try logging in as eduspherestudent@gmail.com (student)
  console.log("Logging in...");
  const loginRes = await postJson(`${baseUrl}/auth/login`, {
    email: 'eduspherestudent@gmail.com',
    password: 'student123'
  });
  
  console.log("Login result:", JSON.stringify(loginRes, null, 2));
  if (!loginRes.body.success) {
    console.error("Login failed!");
    return;
  }
  
  const token = loginRes.body.token;
  const user = loginRes.body.user;
  const studentId = user.student.id;
  console.log(`Student ID: ${studentId}`);
  
  // Test Route 1: students/:studentId/attendance
  console.log(`Testing Route 1: GET ${baseUrl}/students/${studentId}/attendance`);
  const r1 = await getJson(`${baseUrl}/students/${studentId}/attendance`, token);
  console.log("Route 1 Status:", r1.statusCode);
  console.log("Route 1 Body (keys):", Object.keys(r1.body));
  console.log("Route 1 first record:", r1.body.attendance ? r1.body.attendance[0] : null);

  // Test Route 2: attendance/student/:studentId
  console.log(`Testing Route 2: GET ${baseUrl}/attendance/student/${studentId}`);
  const r2 = await getJson(`${baseUrl}/attendance/student/${studentId}`, token);
  console.log("Route 2 Status:", r2.statusCode);
  console.log("Route 2 Body:", typeof r2.body === 'object' ? JSON.stringify(r2.body).substring(0, 500) : r2.body);
}

main();
