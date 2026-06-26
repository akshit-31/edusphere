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
    
    // Kavita Das student ID: d70951be-b1a9-4269-b503-7c08ec55f035
    // Kavita Das user ID: 3f7b0a51-6d42-44e3-af7d-f528874236d3
    
    console.log("Updating Student admissionNumber...");
    const updateStudentQuery = `
      UPDATE public."Student"
      SET "admissionNumber" = 'ADM-2024001'
      WHERE id = 'd70951be-b1a9-4269-b503-7c08ec55f035'
      RETURNING *
    `;
    const studentRes = await client.query(updateStudentQuery);
    console.log("Student updated:");
    console.log(JSON.stringify(studentRes.rows, null, 2));

    console.log("Updating User email...");
    const updateUserQuery = `
      UPDATE public."User"
      SET email = 'kavita.das@edusphere.edu'
      WHERE id = '3f7b0a51-6d42-44e3-af7d-f528874236d3'
      RETURNING *
    `;
    const userRes = await client.query(updateUserQuery);
    console.log("User updated:");
    console.log(JSON.stringify(userRes.rows, null, 2));

  } catch (err) {
    console.error("Error:", err.message);
  } finally {
    await client.end();
  }
}

main();
