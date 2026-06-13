const https = require('https');

const key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE";
const examId = "05984fbb-9a8d-4829-a48b-3f77b2b34c08"; // Mid Term Grade 8 ID

function query() {
  const url = `https://bstevdkjqjzaglayicdg.supabase.co/rest/v1/ExamResult?select=*,Student(*,User(*))&examId=eq.${examId}`;
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
      console.log(`Status: ${res.statusCode}`);
      try {
        const parsed = JSON.parse(data);
        console.log("Results data (first item):");
        console.log(JSON.stringify(parsed[0], null, 2));
      } catch(e) {
        console.log(data);
      }
    });
  }).on('error', (err) => {
    console.error(err);
  });
}

query();
