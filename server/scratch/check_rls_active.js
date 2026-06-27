const { Client } = require('pg');
require('dotenv').config(); // loads .env from Cwd
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

async function main() {
  const dbUri = process.env.DATABASE_URL;
  if (!dbUri) {
    console.error("DATABASE_URL is not set in env!");
    return;
  }
  console.log("Connecting to:", dbUri.split('@')[1] || dbUri);
  
  const client = new Client({ 
    connectionString: dbUri, 
    ssl: { rejectUnauthorized: false } 
  });
  
  try {
    await client.connect();
    console.log("Connected to database successfully!");
    
    console.log("\n--- TABLE RLS STATUS (schema: public) ---");
    const rlsRes = await client.query(`
      SELECT tablename, rowsecurity 
      FROM pg_tables 
      WHERE schemaname = 'public'
      ORDER BY tablename;
    `);
    rlsRes.rows.forEach(r => {
      console.log(`Table: ${r.tablename.padEnd(30)} | RLS Enabled: ${r.rowsecurity}`);
    });

    console.log("\n--- ACTIVE SECURITY POLICIES ---");
    const policiesRes = await client.query(`
      SELECT tablename, policyname, roles, cmd, qual, with_check 
      FROM pg_policies 
      WHERE schemaname = 'public'
      ORDER BY tablename, policyname;
    `);
    if (policiesRes.rows.length === 0) {
      console.log("No custom RLS policies defined in pg_policies.");
    } else {
      policiesRes.rows.forEach(p => {
        console.log(`Table: ${p.tablename} | Policy: ${p.policyname}`);
        console.log(`  Roles: ${p.roles} | Cmd: ${p.cmd}`);
        console.log(`  Using: ${p.qual}`);
        console.log(`  With Check: ${p.with_check}`);
        console.log("-".repeat(50));
      });
    }
    
  } catch (err) {
    console.error("Database connection or query error:", err);
  } finally {
    await client.end();
  }
}

main();
