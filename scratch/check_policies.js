const { Client } = require('pg');

async function main() {
  const password = "akshitsha84";
  const projectRef = "bstevdkjqjzaglayicdg";
  const host = "aws-1-ap-south-1.pooler.supabase.com";
  const dbUri = `postgresql://postgres.${projectRef}:${password}@${host}:6543/postgres`;
  
  const client = new Client({ connectionString: dbUri });
  
  try {
    await client.connect();
    console.log("Connected to PostgreSQL!");
    
    console.log("\n--- TABLE RLS STATUS ---");
    const rlsRes = await client.query(`
      SELECT tablename, rowsecurity 
      FROM pg_tables 
      WHERE schemaname = 'public' 
        AND tablename IN ('Student', 'Class', 'Section', 'User', 'AttendanceRecord', 'students', 'teachers');
    `);
    rlsRes.rows.forEach(r => {
      console.log(`Table: ${r.tablename} | RLS Enabled: ${r.rowsecurity}`);
    });

    console.log("\n--- POLICIES ---");
    const policiesRes = await client.query(`
      SELECT tablename, policyname, roles, cmd, qual, with_check 
      FROM pg_policies 
      WHERE schemaname = 'public' 
        AND tablename IN ('Student', 'Class', 'Section', 'User', 'AttendanceRecord');
    `);
    policiesRes.rows.forEach(p => {
      console.log(`Table: ${p.tablename}`);
      console.log(`  Policy: ${p.policyname}`);
      console.log(`  Roles: ${p.roles}`);
      console.log(`  Command: ${p.cmd}`);
      console.log(`  Using: ${p.qual}`);
      console.log(`  With Check: ${p.with_check}`);
    });
    
  } catch (err) {
    console.error("Error:", err);
  } finally {
    await client.end();
  }
}

main();
