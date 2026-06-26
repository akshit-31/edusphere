process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
const { Client } = require('pg');

async function main() {
    const connectionString = "postgresql://postgres.bstevdkjqjzaglayicdg:akshitsha84@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";
    const client = new Client({ connectionString });
    await client.connect();
    console.log("Connected to bstevdkjqjzaglayicdg successfully!");

    try {
        // Search user student1
        const resUser = await client.query('SELECT id, email, role, "firstName", "lastName" FROM "User" WHERE email = $1', ['student1@edusphere.com']);
        console.log("User search for student1@edusphere.com:", resUser.rows);

        if (resUser.rows.length > 0) {
            const userId = resUser.rows[0].id;
            const resStudent = await client.query('SELECT id, "admissionNumber", "currentClassId", "sectionId" FROM "Student" WHERE "userId" = $1', [userId]);
            console.log("Student search for userId:", resStudent.rows);
        }

        // Search user teacher1
        const resTeacherUser = await client.query('SELECT id, email, role, "firstName", "lastName" FROM "User" WHERE email = $1', ['teacher1@edusphere.com']);
        console.log("User search for teacher1@edusphere.com:", resTeacherUser.rows);

        if (resTeacherUser.rows.length > 0) {
            const userId = resTeacherUser.rows[0].id;
            const resTeacher = await client.query('SELECT id FROM "Teacher" WHERE "userId" = $1', [userId]);
            console.log("Teacher search for userId:", resTeacher.rows);
        }

    } catch (err) {
        console.error("Error executing queries:", err);
    } finally {
        await client.end();
    }
}

main();
