const { createClient } = require('@supabase/supabase-js');
const supabase = createClient('https://bstevdkjqjzaglayicdg.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'); // I need the anon key.

async function run() {
  const fetchSupabase = async (table, method = 'GET') => {
    const res = await fetch(`https://bstevdkjqjzaglayicdg.supabase.co/rest/v1/${table}`, {
      method,
      headers: {
        'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...', // wait, I can get it from scratch/assign_transport.js
      }
    });
    return res.json();
  };
}
