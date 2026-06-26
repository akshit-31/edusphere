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
    
    // 1. Search for Student record by userId
    const studentQuery = `
      SELECT *
      FROM public."Student"
      WHERE "userId" = '3f7b0a51-6d42-44e3-af7d-f528874236d3'
    `;
    const res = await client.query(studentQuery);
    console.log("\n--- Student Records Found ---");
    console.log(JSON.stringify(res.rows, null, 2));

    // 2. Search for any Student record by email sneha.iyengar@edusphere.edu (who was Kavita Bhat)
    // to see if sneha.iyengar is actually the one we want or if it's the other way round.
    
  } catch (err) {
    console.error("Error:", err.message);
  } finally {
    await client.end();
  }
}

main();
