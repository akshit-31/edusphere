process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
const { Client } = require('pg');

const connectionString = "postgresql://postgres.xernedkpgdrvjokokdoa:akshitsha84@aws-1-ap-northeast-2.pooler.supabase.com:5432/postgres?sslmode=require";

async function main() {
    const client = new Client({ connectionString });
    await client.connect();
    console.log("Connected to database successfully!");

    try {
        const email = "student1@edusphere.com";
        const res = await client.query(`
            SELECT s.id as student_id, u.id as user_id, u.email, u."firstName", u."lastName" 
            FROM "Student" s 
            JOIN "User" u ON s."userId" = u.id 
            WHERE u.email = $1
        `, [email]);
        
        console.log(`\nStudent search in DB for email=${email}:`);
        console.log(res.rows);

    } catch (err) {
        console.error("Error executing queries:", err);
    } finally {
        await client.end();
    }
}

main();
