const https = require('https');

const key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE";

const endpoints = [
  'Exam',
  'ExamMark',
  'ExamResult',
  'ExamSchedule',
  'ExamPaper',
  'Class',
  'Term',
  'Subject',
  'AcademicYear'
];

function queryEndpoint(name) {
  const url = `https://bstevdkjqjzaglayicdg.supabase.co/rest/v1/${name}?select=*&limit=1`;
  const options = {
    headers: {
      "apikey": key,
      "Authorization": `Bearer ${key}`
    }
  };

  https.get(url, options, (res) => {
    let data = '';
    res.on('data', (chunk) => { data += chunk; });
    res.on('end', () => {
      console.log(`Endpoint: ${name} | Status: ${res.statusCode}`);
      if (res.statusCode === 200) {
        try {
          const parsed = JSON.parse(data);
          console.log(`  Data:`, parsed);
        } catch(e) {
          console.log(`  Raw:`, data);
        }
      } else {
        console.log(`  Error body:`, data);
      }
    });
  }).on('error', (err) => {
    console.error(`Error querying ${name}:`, err);
  });
}

for (const ep of endpoints) {
  queryEndpoint(ep);
}
