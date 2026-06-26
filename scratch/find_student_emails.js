const { Client } = require('pg');

async function main() {
  const password = "akshitsha84";
  const projectRef = "bstevdkjqjzaglayicdg";
  const host = "aws-1-ap-south-1.pooler.supabase.com";
  const dbUri = `postgresql://postgres.${projectRef}:${password}@${host}:6543/postgres`;
  
  const client = new Client({ connectionString: dbUri });
  
  try {
    await client.connect();
    console.log("Connected!");
    
    // Select some users with role 'student'
    const res = await client.query(`
      SELECT email, role 
      FROM public."User" 
      WHERE role = 'STUDENT'
      LIMIT 10;
    `);
    console.log("Student users in User table:");
    console.log(res.rows);

  } catch (err) {
    console.error("Error:", err.message);
  } finally {
    await client.end();
  }
}

main();
