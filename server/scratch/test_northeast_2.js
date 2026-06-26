const { Client } = require('pg');

const password = 'akshitsha84';
const projectRef = 'xernedkpgdrvjokokdoa';
const host = 'aws-1-ap-northeast-2.pooler.supabase.com';
const user = `postgres.${projectRef}`;

async function testConnection() {
  console.log('--- Testing Connection to aws-1-ap-northeast-2.pooler.supabase.com ---');
  const client = new Client({ 
    host: host,
    port: 6543,
    user: user,
    password: password,
    database: 'postgres',
    connectionTimeoutMillis: 5000,
    ssl: { rejectUnauthorized: false }
  });
  try {
    await client.connect();
    console.log(`🎉 SUCCESS! Connected to ${host}!`);
    const res = await client.query("SELECT COUNT(*) FROM \"User\";");
    console.log(`User count: ${res.rows[0].count}`);
    await client.end();
  } catch (err) {
    console.error(`❌ Connection failed: ${err.message}`);
  }
}

testConnection();
