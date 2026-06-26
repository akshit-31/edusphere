const { Client } = require('pg');

async function main() {
  const password = "akshitsha84";
  const projectRef = "bstevdkjqjzaglayicdg";
  const host = "aws-1-ap-south-1.pooler.supabase.com";
  const dbUri = `postgresql://postgres.${projectRef}:${password}@${host}:6543/postgres`;
  
  const client = new Client({ connectionString: dbUri });
  
  try {
    await client.connect();
    console.log("Connected to PostgreSQL database!");
    
    // Find all users with role 'TEACHER'
    const query = `
      SELECT id, email, "firstName", "lastName", role
      FROM public."User"
      WHERE role = 'TEACHER'
      LIMIT 10
    `;
    const res = await client.query(query);
    console.log("Teachers in DB:");
    console.log(JSON.stringify(res.rows, null, 2));
    
  } catch (err) {
    console.error("Error:", err.message);
  } finally {
    await client.end();
  }
}

main();
