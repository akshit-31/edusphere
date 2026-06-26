process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
const { Client } = require('pg');

const regions = [
    "ap-south-1",      // Mumbai
    "ap-southeast-1",  // Singapore
    "ap-northeast-1",  // Tokyo
    "ap-northeast-2",  // Seoul
    "us-east-1",       // N. Virginia
    "us-east-2",       // Ohio
    "us-west-1",       // N. California
    "us-west-2",       // Oregon
    "eu-central-1",    // Frankfurt
    "eu-west-1",       // Ireland
    "eu-west-2",       // London
    "eu-west-3",       // Paris
    "sa-east-1",       // São Paulo
    "ca-central-1",    // Canada
    "ap-southeast-2",  // Sydney
];

const password = "akshitsha84";
const project_ref = "uodmjwjnhinbbvexbyvd";

async function main() {
    let success = false;
    for (const region of regions) {
        for (const num of ["aws-0", "aws-1"]) {
            const host = `${num}-${region}.pooler.supabase.com`;
            const connectionString = `postgresql://postgres.${project_ref}:${password}@${host}:6543/postgres?sslmode=require`;
            
            const client = new Client({ connectionString });
            try {
                await client.connect();
                console.log(`\nCONNECTED to ${host}!`);
                
                const res = await client.query('SELECT COUNT(*) FROM "User"');
                console.log(`User count: ${res.rows[0].count}`);
                
                // Let's search for student1
                const userSearch = await client.query('SELECT id, email, role, "firstName", "lastName" FROM "User" WHERE email = $1', ['student1@edusphere.com']);
                console.log("Student search in this DB:", userSearch.rows);

                await client.end();
                success = true;
                break;
            } catch (err) {
                // Ignore failure and continue
            }
        }
        if (success) break;
    }
    if (!success) {
        console.log("Could not connect to any pooler.");
    }
}

main();
