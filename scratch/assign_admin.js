async function run() {
  try {
    // 1. Login as Admin
    let token = null;
    const loginRes = await fetch("https://edusphere-erp-frontend.onrender.com/api/v1/auth/login", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: "edusphereadmin@gmail.com", password: "admin" })
    });
    let loginData = await loginRes.json();
    if (loginRes.ok) token = loginData.token;
    else {
      const loginRes2 = await fetch("https://edusphere-erp-frontend.onrender.com/api/v1/auth/login", {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: "edusphereadmin@gmail.com", password: "admin123" })
      });
      loginData = await loginRes2.json();
      if (loginRes2.ok) token = loginData.token;
    }
    if (!token) throw new Error('All passwords failed for admin');
    console.log('Admin Token acquired.');

    // 2. Fetch all students
    console.log('Fetching all students...');
    const studentsRes = await fetch("https://edusphere-erp-frontend.onrender.com/api/v1/students", {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    const studentsData = await studentsRes.json();
    if (!studentsData.success) throw new Error('Failed to fetch students');
    
    // Find student1@edusphere.com
    const student = studentsData.data?.find(s => s.user?.email === 'student1@edusphere.com' || s.email === 'student1@edusphere.com');
    if (!student) {
      console.log('student1@edusphere.com not found in students list!');
      // print available students
      console.log('Available student emails:', studentsData.data?.map(s => s.user?.email || s.email).slice(0, 10));
      return;
    }
    console.log('Found student!', student.id);

    // 3. Fetch all routes
    console.log('Fetching routes...');
    const routesRes = await fetch("https://edusphere-erp-frontend.onrender.com/api/v1/transport/routes", {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    const routesData = await routesRes.json();
    const routes = routesData.data || routesData.routes;
    if (!routes || routes.length === 0) throw new Error('No routes available');
    const routeId = routes[0].id;
    console.log('Selected route:', routeId);

    // 4. Assign transport
    console.log('Assigning transport...');
    const assignRes = await fetch("https://edusphere-erp-frontend.onrender.com/api/v1/transport/allocations", {
      method: 'POST',
      headers: { 
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        studentId: student.id,
        routeId: routeId,
        stopId: routes[0].stops?.[0]?.id || undefined, // if required
      })
    });
    const assignData = await assignRes.json();
    console.log('Assignment Result:', assignData);

  } catch(e) {
    console.error(e);
  }
}
run();
