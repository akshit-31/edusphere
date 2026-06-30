const axios = require('axios');

async function main() {
  const loginUrl = 'https://edusphere-erp-frontend.onrender.com/api/v1/auth/login';
  
  try {
    const loginRes = await axios.post(loginUrl, {
      email: 'student1@edusphere.com',
      password: 'Password@123'
    });
    
    const token = loginRes.data.token;
    const headers = { Authorization: `Bearer ${token}` };
    
    // Fetch student's profile or class teacher info if available
    const profileRes = await axios.get('https://edusphere-erp-frontend.onrender.com/api/v1/students/profile', { headers });
    console.log('Student Profile class/teacher:', JSON.stringify(profileRes.data.student?.currentClass || profileRes.data.student?.class, null, 2));
    
  } catch (error) {
    console.error('Error:', error.response?.status, error.response?.data || error.message);
  }
}

main();
