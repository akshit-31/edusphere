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
    
    // Check constraints on public.AttendanceRecord
    const constraintQuery = `
      SELECT conname, pg_get_constraintdef(c.oid)
      FROM pg_constraint c
      JOIN pg_namespace n ON n.oid = c.connamespace
      WHERE n.nspname = 'public' AND c.conrelid = 'public."AttendanceRecord"'::regclass
    `;
    const constraintRes = await client.query(constraintQuery);
    console.log("Constraints:");
    console.log(JSON.stringify(constraintRes.rows, null, 2));

    // Check unique indexes
    const indexQuery = `
      SELECT indexname, indexdef
      FROM pg_indexes
      WHERE schemaname = 'public' AND tablename = 'AttendanceRecord'
    `;
    const indexRes = await client.query(indexQuery);
    console.log("Indexes:");
    console.log(JSON.stringify(indexRes.rows, null, 2));
    
  } catch (err) {
    console.error("Error:", err.message);
  } finally {
    await client.end();
  }
}

main();
