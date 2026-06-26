const { Client } = require('pg');
const bcrypt = require('bcryptjs');

async function main() {
  const password = "akshitsha84";
  const projectRef = "bstevdkjqjzaglayicdg";
  const host = "aws-1-ap-south-1.pooler.supabase.com";
  const dbUri = `postgresql://postgres.${projectRef}:${password}@${host}:6543/postgres`;
  
  const client = new Client({ connectionString: dbUri });
  
  try {
    await client.connect();
    console.log("Connected!");
    
    // Query users with different roles
    const res = await client.query(`
      SELECT id, email, role, password, "firstName", "lastName"
      FROM public."User" 
      LIMIT 10;
    `);
    
    console.log("\nUsers in DB:");
    for (const r of res.rows) {
      console.log(`Email: ${r.email} | Role: ${r.role} | Name: ${r.firstName} ${r.lastName}`);
      // Test if password is 'student123' or 'teacher123' or 'admin123' or 'edusphere'
      const possiblePasswords = ['student123', 'teacher123', 'admin123', 'edusphere', 'Student@123', 'Teacher@123', 'Student@2024'];
      for (const p of possiblePasswords) {
        try {
          const match = await bcrypt.compare(p, r.password);
          if (match) {
            console.log(`  --> Password MATCH found: "${p}"`);
          }
        } catch(e) {}
      }
    }
  } catch (err) {
    console.error("Error:", err.message);
  } finally {
    await client.end();
  }
}

main();
