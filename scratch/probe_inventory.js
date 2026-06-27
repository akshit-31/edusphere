async function main() {
  const email = 'teacher1@edusphere.com';
  const password = 'Password@123';
  const baseUrl = 'https://edusphere-erp-frontend.onrender.com/api/v1';

  console.log("Logging in...");
  const loginRes = await fetch(`${baseUrl}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  });

  const loginData = await loginRes.json();
  const token = loginData.token;
  console.log("Logged in! Token obtained.");

  const headers = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  };

  const endpoints = [
    '/inventory/items',
    '/inventory/requests',
    '/inventory/requisitions',
    '/inventory/requisition',
    '/inventory/movements',
    '/services',
  ];

  for (const ep of endpoints) {
    try {
      console.log(`\nProbing GET ${ep}...`);
      const res = await fetch(`${baseUrl}${ep}`, { headers });
      console.log(`Status: ${res.status}`);
      const data = await res.json();
      console.log("Keys:", Object.keys(data));
      const dataStr = JSON.stringify(data, null, 2);
      console.log(dataStr.length > 500 ? dataStr.slice(0, 500) + "\n...truncated..." : dataStr);
    } catch (err) {
      console.log(`Failed!`, err);
    }
  }
}

main().catch(e => console.error("Unhandled error:", e));
