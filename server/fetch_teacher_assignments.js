const axios = require('axios');

async function main() {
  const loginUrl = 'https://edusphere-erp-frontend.onrender.com/api/v1/auth/login';
  
  try {
    const loginRes = await axios.post(loginUrl, {
      email: 'teacher1@edusphere.com',
      password: 'Password@123'
    });
    
    const token = loginRes.data.token;
    const headers = { Authorization: `Bearer ${token}` };
    
    const res = await axios.get('https://edusphere-erp-frontend.onrender.com/api/v1/assignments/teacher', { headers });
    console.log('Teacher assignments response:', JSON.stringify(res.data, null, 2));
  } catch (error) {
    console.error('Error:', error.response?.status, error.response?.data || error.message);
  }
}

main();
