async function run() {
  try {
    let token = null;
    const loginRes = await fetch("https://edusphere-erp-frontend.onrender.com/api/v1/auth/login", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: "eduspherestudent@gmail.com", password: "student123" })
    });
    const loginData = await loginRes.json();
    if (!loginRes.ok) throw new Error('Student login failed: ' + JSON.stringify(loginData));
    token = loginData.token;

    console.log('Fetching fees...');
    const feesRes = await fetch("https://edusphere-erp-frontend.onrender.com/api/v1/fees", {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    console.log(await feesRes.text());
    
    console.log('Fetching my fees...');
    const feesMyRes = await fetch("https://edusphere-erp-frontend.onrender.com/api/v1/fees/my", {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    console.log(await feesMyRes.text());
  } catch(e) {
    console.error(e);
  }
}
run();
