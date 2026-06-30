const https = require('https');

async function request(options, postData) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(body);
          resolve({ status: res.statusCode, headers: res.headers, data: json });
        } catch (_) {
          resolve({ status: res.statusCode, headers: res.headers, data: body });
        }
      });
    });
    req.on('error', (err) => reject(err));
    if (postData) {
      req.write(postData);
    }
    req.end();
  });
}

async function main() {
  const loginRes = await request({
    hostname: 'edusphere-erp-frontend.onrender.com',
    port: 443,
    path: '/api/v1/auth/login',
    method: 'POST',
    headers: { 'Content-Type': 'application/json' }
  }, JSON.stringify({
    email: 'teacher1@edusphere.com',
    password: 'Password@123'
  }));

  const token = loginRes.data.token;

  // Omit classId and sectionId to query "All Classes" & "All Sections"
  const path = `/api/v1/attendance/analytics?startDate=2026-05-31&endDate=2026-06-30&attendeeType=STUDENT`;
  const analyticsRes = await request({
    hostname: 'edusphere-erp-frontend.onrender.com',
    port: 443,
    path,
    method: 'GET',
    headers: { 'Authorization': `Bearer ${token}` }
  });

  console.log("Summary:", JSON.stringify(analyticsRes.data.data.summary, null, 2));
  console.log("Daily Breakdown Count:", analyticsRes.data.data.dailyBreakdown.length);
  console.log("First 3 Daily Breakdown items:", JSON.stringify(analyticsRes.data.data.dailyBreakdown.slice(0, 3), null, 2));
}

main();
