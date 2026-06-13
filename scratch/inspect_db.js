const https = require('https');

const url = "https://bstevdkjqjzaglayicdg.supabase.co/rest/v1/";
const key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE";

const options = {
  headers: {
    "apikey": key,
    "Authorization": `Bearer ${key}`
  }
};

https.get(url, options, (res) => {
  console.log("Status Code:", res.statusCode);
  let data = '';
  res.on('data', (chunk) => { data += chunk; });
  res.on('end', () => {
    console.log("Body length:", data.length);
    console.log("Preview:", data.substring(0, 500));
    try {
      const parsed = JSON.parse(data);
      console.log("Keys in parsed:", Object.keys(parsed));
      if (parsed.definitions) {
        console.log("Definitions keys count:", Object.keys(parsed.definitions).length);
        const definitions = Object.keys(parsed.definitions);
        for (const def of definitions) {
          console.log(` - ${def}`);
          if (def.includes('Exam') || def.includes('Schedule')) {
            console.log("   Columns:");
            const props = parsed.definitions[def].properties;
            for (const prop in props) {
              console.log(`     ${prop}: ${props[prop].type} (${props[prop].format || ''})`);
            }
          }
        }
      }
    } catch (e) {
      console.error("Parse error:", e);
    }
  });
}).on('error', (err) => {
  console.error("HTTP error:", err);
});
