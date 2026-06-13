const https = require('https');

const key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE";

function query(url, label) {
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
      console.log(`=== ${label} ===`);
      try {
        const parsed = JSON.parse(data);
        console.log(JSON.stringify(parsed, null, 2));
      } catch(e) {
        console.log(data);
      }
    });
  }).on('error', (err) => {
    console.error(`Error querying ${label}:`, err);
  });
}

// Query all ExamMarks and join with ExamResult to see which Exam they correspond to
query("https://bstevdkjqjzaglayicdg.supabase.co/rest/v1/ExamMark?select=*,ExamResult(id,examId,studentId)", "ExamMarks");
