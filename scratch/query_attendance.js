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
    
    // Query records on or after June 1st, 2026
    const countQuery = `
      SELECT COUNT(*) as total
      FROM public."AttendanceRecord"
    `;
    const countRes = await client.query(countQuery);
    console.log("Total attendance records in DB:", countRes.rows[0].total);

    const juneQuery = `
      SELECT r.id, r."studentId", r.date, r.status, r."createdAt",
             u."firstName", u."lastName"
      FROM public."AttendanceRecord" r
      JOIN public."Student" s ON r."studentId" = s.id
      JOIN public."User" u ON s."userId" = u.id
      WHERE r.date >= '2026-06-01'
      ORDER BY r.date DESC
      LIMIT 20
    `;
    const res = await client.query(juneQuery);
    console.log("\n--- June 2026 Attendance Records (Max 20) ---");
    console.log(JSON.stringify(res.rows, null, 2));
    
  } catch (err) {
    console.error("Error:", err.message);
  } finally {
    await client.end();
  }
}

main();
