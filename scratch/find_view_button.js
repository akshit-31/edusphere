const fs = require('fs');
const content = fs.readFileSync('lib/screens/features/create_assignment_screen.dart', 'utf8');
const lines = content.split('\n');

lines.forEach((line, idx) => {
  if (line.toLowerCase().includes('view') && (line.includes('button') || line.includes('Text') || line.includes('GestureDetector'))) {
    console.log(`${idx + 1}: ${line.trim()}`);
  }
});
