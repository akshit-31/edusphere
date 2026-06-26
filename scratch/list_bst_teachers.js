process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
const { Client } = require('pg');

async function main() {
    const connectionString = "postgresql://postgres.bstevdkjqjzaglayicdg:akshitsha84@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";
    const client = new Client({ connectionString });
    await client.connect();
    console.log("Connected to bstevdkjqjzaglayicdg successfully!");

    try {
        const res = await client.query('SELECT id, email, role, "firstName", "lastName" FROM "User" WHERE role = \'TEACHER\' LIMIT 20');
        console.log(`\nFound ${res.rows.length} teachers in bstevdkjqjzaglayicdg:`);
        res.rows.forEach(u => {
            console.log(`  email: ${u.email} | role: ${u.role} | name: ${u.firstName} ${u.lastName} | id: ${u.id}`);
        });

    } catch (err) {
        console.error("Error executing queries:", err);
    } finally {
        await client.end();
    }
}

main();
