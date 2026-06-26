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

    const tables = ['Student', 'Teacher', 'Class', 'Section', 'AttendanceRecord'];
    for (const table of tables) {
      const query = `
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns 
        WHERE table_name = '${table}'
        ORDER BY ordinal_position;
      `;
      const res = await client.query(query);
      console.log(`\n--- Columns in ${table} ---`);
      console.log(res.rows.map(r => `${r.column_name}: ${r.data_type} (nullable: ${r.is_nullable})`).join('\n'));
    }
  } catch (err) {
    console.error("Error:", err.message);
  } finally {
    await client.end();
  }
}

main();
