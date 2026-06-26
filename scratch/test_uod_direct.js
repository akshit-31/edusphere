process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
const { Client } = require('pg');

async function main() {
    const project_ref = "uodmjwjnhinbbvexbyvd";
    const password = "akshitsha84";
    
    const configs = [
        // Direct connection
        { host: `db.${project_ref}.supabase.co`, port: 5432, user: 'postgres' },
        { host: `db.${project_ref}.supabase.co`, port: 5432, user: `postgres.${project_ref}` },
        // Pooler hosts
        { host: `aws-1-ap-south-1.pooler.supabase.com`, port: 5432, user: `postgres.${project_ref}` },
        { host: `aws-0-ap-south-1.pooler.supabase.com`, port: 6543, user: `postgres.${project_ref}` },
        { host: `aws-1-ap-south-1.pooler.supabase.com`, port: 6543, user: `postgres.${project_ref}` }
    ];

    for (const cfg of configs) {
        console.log(`Connecting to ${cfg.host}:${cfg.port} with user ${cfg.user}...`);
        const client = new Client({
            host: cfg.host,
            port: cfg.port,
            database: 'postgres',
            user: cfg.user,
            password: password,
            ssl: { rejectUnauthorized: false },
            connectionTimeoutMillis: 5000
        });

        try {
            await client.connect();
            console.log("🎉 SUCCESS! Connected to database!");
            
            // Search for student
            const resStudent = await client.query(`
                SELECT s.id as student_id, u.id as user_id, u.email, u."firstName", u."lastName" 
                FROM "Student" s 
                JOIN "User" u ON s."userId" = u.id 
                WHERE u.email = 'student1@edusphere.com'
            `);
            console.log("Student search results:", resStudent.rows);

            // Search for teacher
            const resTeacher = await client.query(`
                SELECT t.id as teacher_id, u.id as user_id, u.email, u."firstName", u."lastName" 
                FROM "Teacher" t 
                JOIN "User" u ON t."userId" = u.id 
                WHERE u.email = 'teacher1@edusphere.com'
            `);
            console.log("Teacher search results:", resTeacher.rows);

            await client.end();
            return;
        } catch (err) {
            console.log(`  Failed: ${err.message}`);
        }
    }
    console.log("❌ All connection attempts failed.");
}

main();
