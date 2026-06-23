async function login() {
  try {
    const res = await fetch("https://edusphere-erp-frontend.onrender.com/api/v1/auth/login", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: "student1@edusphere.edu", password: "edusphere" })
    });
    console.log('Status:', res.status);
    const data = await res.json();
    if (res.ok) {
      console.log('Logged in successfully!');
      console.log('User ID:', data.user.id);
      console.log('Student ID:', data.user.student?.id);
    } else {
      console.log('Login failed:', data);
    }
  } catch(e) {
    console.error(e);
  }
}
login();
