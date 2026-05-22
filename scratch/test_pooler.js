const { Client } = require('pg');

async function main() {
  const dbUri = "postgresql://postgres.xernedkpgdrvjokokdoa:akshitsha84@aws-0-ap-northeast-2.pooler.supabase.com:6543/postgres";
  console.log("Testing connection via Node.js with pooler...");
  const client = new Client({
    connectionString: dbUri,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    console.log("🎉 SUCCESS! Connected successfully via Node.js pooler!");
    const res = await client.query("SELECT COUNT(*) FROM public.students;");
    console.log("Student count:", res.rows[0].count);
  } catch (err) {
    console.error("Connection failed:", err.message);
  } finally {
    await client.end();
  }
}

main();
