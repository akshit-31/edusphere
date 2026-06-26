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
    
    // Check existing publication tables
    const checkQuery = `
      SELECT tablename 
      FROM pg_publication_tables 
      WHERE pubname = 'supabase_realtime';
    `;
    const checkRes = await client.query(checkQuery);
    const existing = new Set(checkRes.rows.map(r => r.tablename));
    console.log("Existing publication tables:", Array.from(existing));
    
    const tablesToAdd = [
      "Student",
      "User",
      "Assignment",
      "AssignmentSubmission",
      "AttendanceRecord",
      "StudentFeeLedger",
      "LibraryIssue",
      "SchoolCalendar",
      "ExamResult",
      "ReportCard"
    ];
    
    for (const table of tablesToAdd) {
      if (!existing.has(table)) {
        try {
          await client.query(`ALTER PUBLICATION supabase_realtime ADD TABLE "${table}";`);
          console.log(`Successfully added '${table}' to supabase_realtime publication.`);
        } catch (ex) {
          console.error(`Error adding '${table}':`, ex.message);
        }
      } else {
        console.log(`Table '${table}' is already in the publication.`);
      }
    }
    
  } catch (err) {
    console.error("Error:", err.message);
  } finally {
    await client.end();
  }
}

main();
