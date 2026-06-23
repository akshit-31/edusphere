async function run() {
  try {
    const loginRes = await fetch("https://edusphere-erp-frontend.onrender.com/api/v1/auth/login", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: "edusphereadmin@gmail.com", password: "admin123" })
    });
    const loginData = await loginRes.json();
    if (!loginRes.ok) throw new Error('Login failed: ' + JSON.stringify(loginData));
    const token = loginData.token;

    console.log('Fetching /api/v1/fees/students/me/status...');
    const res1 = await fetch("https://edusphere-erp-frontend.onrender.com/api/v1/fees/students/me/status", {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    console.log('Status:', res1.status);
    console.log(await res1.text());

    console.log('Fetching /api/v1/fees...');
    const res2 = await fetch("https://edusphere-erp-frontend.onrender.com/api/v1/fees", {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    console.log('Status:', res2.status);
    console.log(await res2.text());
  } catch(e) {
    console.error(e);
  }
}
run();
