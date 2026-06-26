const fs = require('fs');
const path = require('path');

const srcDir = path.join(__dirname, '..', 'src');

function walkDir(dir, callback) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    if (stat.isDirectory()) {
      walkDir(filePath, callback);
    } else if (file.endsWith('.js')) {
      callback(filePath);
    }
  }
}

console.log('🔄 Starting Prisma model name refactoring...');

let refactoredCount = 0;

walkDir(srcDir, (filePath) => {
  let content = fs.readFileSync(filePath, 'utf8');
  let modified = false;

  // Replace prisma.student with prisma.studentProfile (using word boundaries)
  if (/\bprisma\.student\b/g.test(content)) {
    content = content.replace(/\bprisma\.student\b/g, 'prisma.studentProfile');
    modified = true;
    console.log(`- Refactored student model in: ${path.relative(srcDir, filePath)}`);
  }

  // Replace prisma.parent with prisma.parentProfile
  if (/\bprisma\.parent\b/g.test(content)) {
    content = content.replace(/\bprisma\.parent\b/g, 'prisma.parentProfile');
    modified = true;
    console.log(`- Refactored parent model in: ${path.relative(srcDir, filePath)}`);
  }

  if (modified) {
    fs.writeFileSync(filePath, content, 'utf8');
    refactoredCount++;
  }
});

console.log(`\n🎉 Refactoring complete! Updated ${refactoredCount} files.`);
