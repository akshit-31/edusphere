const fs = require('fs');
const path = require('path');

const srcDir = path.join(__dirname, '..', 'server', 'src');

console.log("Analyzing server files for security and quality patterns...");

function searchPatternInFile(filePath, regex) {
  if (!fs.existsSync(filePath)) return false;
  const content = fs.readFileSync(filePath, 'utf8');
  return regex.test(content);
}

const modules = {
  auth: { route: 'authRoutes.js', controller: 'authController.js', service: 'auth_service.dart' },
  student: { route: 'studentRoutes.js', controller: 'studentController.js', service: 'studentService.js' },
  teacher: { route: 'teacherRoutes.js', controller: 'teacherController.js', service: 'studentService.js' },
  attendance: { route: 'attendanceRoutes.js', controller: 'attendanceController.js', service: 'AttendanceService.js' },
  homework: { route: 'assignmentRoutes.js', controller: 'assignmentController.js', service: 'studentService.js' },
  quiz: { route: 'quizRoutes.js', controller: 'quizController.js', service: 'studentService.js' },
  fees: { route: 'feeRoutes.js', controller: 'feeController.js', service: 'feeService.js' },
  library: { route: 'libraryRoutes.js', controller: 'libraryController.js', service: 'LibraryService.js' },
  transport: { route: 'transportRoutes.js', controller: 'transportController.js', service: 'TransportService.js' },
  notifications: { route: 'notificationRoutes.js', controller: 'notificationController.js', service: 'NotificationService.js' },
  exams: { route: 'examRoutes.js', controller: 'examController.js', service: 'ExamService.js' }
};

for (const [name, files] of Object.entries(modules)) {
  const rPath = path.join(srcDir, 'routes', files.route);
  const cPath = path.join(srcDir, 'controllers', files.controller);
  
  console.log(`\nModule: ${name.toUpperCase()}`);
  console.log(`  - Route file exists: ${fs.existsSync(rPath)}`);
  console.log(`  - Controller file exists: ${fs.existsSync(cPath)}`);
  
  if (fs.existsSync(rPath)) {
    const authCheck = searchPatternInFile(rPath, /authMiddleware|isAuthenticated/);
    const roleCheck = searchPatternInFile(rPath, /roleCheck|isAdmin|isTeacher|isStudent/);
    console.log(`  - Authentication middleware check: ${authCheck}`);
    console.log(`  - Role Authorization check: ${roleCheck}`);
  }
  
  if (fs.existsSync(cPath)) {
    const tryCatch = searchPatternInFile(cPath, /try\s*\{[\s\S]*\}\s*catch/);
    const validationCheck = searchPatternInFile(cPath, /validate|validationResult/);
    console.log(`  - Error handling try-catch: ${tryCatch}`);
    console.log(`  - Validation check: ${validationCheck}`);
  }
}
