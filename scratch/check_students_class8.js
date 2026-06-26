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
    
    // Class 8 ID: eca75480-c96e-4ea6-8e66-c934a89c9bc0
    // Section A ID: ba6e2d2f-da7e-49fa-be31-5369fe5991fb
    const query = `
      SELECT s.id, s."admissionNumber", u."firstName", u."lastName", u.email, s."sectionId"
      FROM public."Student" s
      JOIN public."User" u ON s."userId" = u.id
      WHERE s."currentClassId" = 'eca75480-c96e-4ea6-8e66-c934a89c9bc0'
    `;
    const res = await client.query(query);
    console.log("Students in Class 8:");
    console.log(JSON.stringify(res.rows, null, 2));
    
  } catch (err) {
    console.error("Error:", err.message);
  } finally {
    await client.end();
  }
}

main();
