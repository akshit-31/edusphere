process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
const { Client } = require('pg');

const connectionString = "postgresql://postgres.bstevdkjqjzaglayicdg:akshitsha84@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";

async function main() {
    const client = new Client({ connectionString });
    await client.connect();
    console.log("Connected to database successfully!");

    try {
        const usersRes = await client.query(`
            SELECT id, email, role, "firstName", "lastName" 
            FROM "User" 
            WHERE email LIKE '%@edusphere.com'
        `);
        console.log(`\nFound ${usersRes.rows.length} users with @edusphere.com in bstevdkjqjzaglayicdg:`);
        usersRes.rows.forEach(u => {
            console.log(`  email: ${u.email} | role: ${u.role} | name: ${u.firstName} ${u.lastName} | id: ${u.id}`);
        });

    } catch (err) {
        console.error("Error executing queries:", err);
    } finally {
        await client.end();
    }
}

main();
