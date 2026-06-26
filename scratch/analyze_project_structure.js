const fs = require('fs');
const path = require('path');

const projectRoot = path.join(__dirname, '..');
const libDir = path.join(projectRoot, 'lib');
const serverDir = path.join(projectRoot, 'server');

let fileCount = 0;
let totalLines = 0;
const fileExtensions = {};

function scanDirectory(dir) {
  if (!fs.existsSync(dir)) return;
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      if (file !== 'node_modules' && file !== '.git' && file !== 'build' && file !== '.dart_tool') {
        scanDirectory(fullPath);
      }
    } else {
      fileCount++;
      const ext = path.extname(file) || 'no-extension';
      fileExtensions[ext] = (fileExtensions[ext] || 0) + 1;
      
      try {
        const content = fs.readFileSync(fullPath, 'utf8');
        const lines = content.split('\n').length;
        totalLines += lines;
      } catch (e) {
        // Binary files or read errors
      }
    }
  }
}

console.log("Starting full project file scan...");
scanDirectory(projectRoot);

console.log(`\nScan Results:`);
console.log(`Total Files: ${fileCount}`);
console.log(`Total Lines of Code: ${totalLines}`);
console.log(`File Extensions breakdown:`, JSON.stringify(fileExtensions, null, 2));

// Scan server/src directories
function listDirContents(subDir) {
  const dirPath = path.join(serverDir, 'src', subDir);
  if (fs.existsSync(dirPath)) {
    console.log(`\nFiles in server/src/${subDir}:`);
    fs.readdirSync(dirPath).forEach(f => console.log(`  - ${f}`));
  }
}

listDirContents('routes');
listDirContents('controllers');
listDirContents('services');

// Scan lib/screens directories
const screensDir = path.join(libDir, 'screens');
if (fs.existsSync(screensDir)) {
  console.log(`\nDirectories/Files in lib/screens:`);
  function scanLibScreens(dir, depth = 0) {
    fs.readdirSync(dir).forEach(file => {
      const fullPath = path.join(dir, file);
      const stat = fs.statSync(fullPath);
      const indent = "  ".repeat(depth);
      if (stat.isDirectory()) {
        console.log(`${indent}[DIR] ${file}`);
        scanLibScreens(fullPath, depth + 1);
      } else {
        console.log(`${indent}- ${file}`);
      }
    });
  }
  scanLibScreens(screensDir);
}
