const { Client } = require('pg');

const regions = [
  'ap-south-1',      // Mumbai
  'ap-southeast-1',  // Singapore
  'ap-northeast-1',  // Tokyo
  'ap-northeast-2',  // Seoul
  'us-east-1',       // N. Virginia
  'us-east-2',       // Ohio
  'us-west-1',       // N. California
  'us-west-2',       // Oregon
  'eu-central-1',    // Frankfurt
  'eu-west-1',       // Ireland
  'eu-west-2',       // London
  'eu-west-3',       // Paris
  'sa-east-1',       // São Paulo
  'ca-central-1',    // Canada
  'ap-southeast-2',  // Sydney
];

const password = 'akshitsha84';
const projectRef = 'xernedkpgdrvjokokdoa';

async function testRegions() {
  console.log('--- Testing Pooled Connections via discrete config params for xernedkpgdrvjokokdoa ---');
  for (const region of regions) {
    const host = `aws-0-${region}.pooler.supabase.com`;
    const user = `postgres.${projectRef}`;
    console.log(`Testing pooled connection on ${region}...`);
    const pooledClient = new Client({ 
      host: host,
      port: 6543,
      user: user,
      password: password,
      database: 'postgres',
      connectionTimeoutMillis: 5000,
      ssl: { rejectUnauthorized: false }
    });
    try {
      await pooledClient.connect();
      console.log(`🎉 SUCCESS! Connected to pooled ${region}!`);
      console.log(`Host: ${host}, User: ${user}`);
      await pooledClient.end();
      return;
    } catch (err) {
      console.log(`  Failed on ${region}: ${err.message.substring(0, 100)}`);
    }
  }
  console.log('❌ All regional poolers failed.');
}

testRegions();
