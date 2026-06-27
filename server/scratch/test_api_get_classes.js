const axios = require('axios');

async function test() {
  try {
    console.log("Attempting login as teacher2@edusphere.com...");
    const loginRes = await axios.post('http://localhost:5001/api/v1/auth/login', {
      email: 'teacher2@edusphere.com',
      password: 'Password@123'
    });

    const token = loginRes.data.token;
    console.log("Login successful! Token acquired.");

    console.log("Fetching classes via GET /api/v1/academic/classes...");
    const classesRes = await axios.get('http://localhost:5001/api/v1/academic/classes', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });

    console.log("Classes response status:", classesRes.status);
    console.log("Classes found:");
    const classes = classesRes.data.classes || classesRes.data.data || [];
    for (const c of classes) {
      console.log(`- ${c.name} (ID: ${c.id})`);
    }

    console.log("Fetching sections via GET /api/v1/academic/sections...");
    const sectionsRes = await axios.get('http://localhost:5001/api/v1/academic/sections', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });
    console.log("Sections response status:", sectionsRes.status);
    const sections = sectionsRes.data.sections || sectionsRes.data.data || [];
    console.log(`Found ${sections.length} total sections.`);

  } catch (err) {
    console.error("❌ Test failed:", err.response ? err.response.data : err.message);
  }
}

test();
