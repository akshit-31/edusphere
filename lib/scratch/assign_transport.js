const SUPABASE_URL = 'https://bstevdkjqjzaglayicdg.supabase.co';
const ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE';

async function fetchSupabase(table, method = 'GET', body = null, query = '') {
  const url = `${SUPABASE_URL}/rest/v1/${table}${query}`;
  const headers = {
    'apikey': ANON_KEY,
    'Authorization': `Bearer ${ANON_KEY}`,
    'Content-Type': 'application/json',
  };
  if (method === 'POST') headers['Prefer'] = 'return=representation';
  
  const options = { method, headers };
  if (body) options.body = JSON.stringify(body);
  
  const res = await fetch(url, options);
  if (!res.ok) {
    const text = await res.text();
    console.error('Error fetching', table, text);
    throw new Error(text);
  }
  if (res.status === 204) return null;
  return await res.json();
}

async function run() {
  try {
    const emails = ['eduspherestudent@gmail.com', 'testuser@edusphere.edu', 'student1@edusphere.com'];
    for (const email of emails) {
      console.log(`\n--- Assigning for ${email} ---`);
      const users = await fetchSupabase('User', 'GET', null, `?email=eq.${email}`);
      if (!users.length) {
        console.log(`User not found: ${email}`);
        continue;
      }
      const userId = users[0].id;
      
      const students = await fetchSupabase('Student', 'GET', null, `?userId=eq.${userId}`);
      if (!students.length) {
        console.log(`Student not found for ${email}`);
        continue;
      }
      const studentId = students[0].id;
      
      const allocs = await fetchSupabase('TransportAllocation', 'GET', null, `?studentId=eq.${studentId}`);
      if (allocs.length > 0) {
        console.log(`Already has allocation:`, allocs[0]);
        // Update to ACTIVE just in case
        await fetchSupabase(`TransportAllocation?id=eq.${allocs[0].id}`, 'PATCH', { status: 'ACTIVE' });
        console.log('Set status to ACTIVE');
        continue;
      }
      
      const routes = await fetchSupabase('TransportRoute', 'GET', null, '?select=id,name');
      let routeId, stopId;
      if (routes.length === 0) {
        console.log('Creating a route...');
        const newRoute = await fetchSupabase('TransportRoute', 'POST', { name: 'Route 1', vehicleNumber: 'DL 1A 1234', driverName: 'Raj Kumar', driverPhone: '9876543210' });
        routeId = newRoute[0].id;
      } else {
        routeId = routes[0].id;
      }
      
      const stops = await fetchSupabase('RouteStop', 'GET', null, `?routeId=eq.${routeId}`);
      if (stops.length === 0) {
        console.log('Creating a stop...');
        const newStop = await fetchSupabase('RouteStop', 'POST', { routeId, name: 'Main Gate', time: '08:00 AM', pickupTime: '08:00 AM', dropTime: '03:00 PM', sequenceOrder: 1, stopOrder: 1 });
        stopId = newStop[0].id;
      } else {
        stopId = stops[0].id;
      }
      
      const insertRes = await fetchSupabase('TransportAllocation', 'POST', {
        studentId,
        routeId,
        stopId,
        status: 'ACTIVE'
      });
      console.log(`Success assigned for ${email}`);
    }
  } catch (e) {
    console.error('Failed:', e);
  }
}

run();
