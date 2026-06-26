const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function runAudit() {
  console.log('--- STARTING DATABASE RELATIONSHIP AUDIT ---');
  try {
    // 1. Table Counts
    const usersCount = await prisma.user.count();
    const studentsCount = await prisma.student.count();
    const teachersCount = await prisma.teacher.count();
    const classesCount = await prisma.class.count();
    const sectionsCount = await prisma.section.count();
    const attendanceRecordsCount = await prisma.attendanceRecord.count();
    const attendanceSlotsCount = await prisma.attendanceSlot.count();

    console.log(`\nTable Counts:`);
    console.log(`- Users: ${usersCount}`);
    console.log(`- Students: ${studentsCount}`);
    console.log(`- Teachers: ${teachersCount}`);
    console.log(`- Classes: ${classesCount}`);
    console.log(`- Sections: ${sectionsCount}`);
    console.log(`- Attendance Records: ${attendanceRecordsCount}`);
    console.log(`- Attendance Slots: ${attendanceSlotsCount}`);

    // 2. Duplicate Student IDs Check (userId or admissionNumber)
    console.log('\nChecking for duplicates in Student table...');
    const duplicateAdmissions = await prisma.$queryRaw`
      SELECT "admissionNumber", COUNT(*) as count 
      FROM "Student" 
      GROUP BY "admissionNumber" 
      HAVING COUNT(*) > 1
    `;
    console.log(`- Duplicate admission numbers: ${JSON.stringify(duplicateAdmissions)}`);

    const duplicateStudentUsers = await prisma.$queryRaw`
      SELECT "userId", COUNT(*) as count 
      FROM "Student" 
      GROUP BY "userId" 
      HAVING COUNT(*) > 1
    `;
    console.log(`- Duplicate Student userIds: ${JSON.stringify(duplicateStudentUsers)}`);

    // 3. Orphaned Attendance Records (records pointing to non-existent student/teacher/staff)
    console.log('\nChecking for orphaned Attendance records...');
    const orphanedStudents = await prisma.$queryRaw`
      SELECT COUNT(*) as count 
      FROM "AttendanceRecord" 
      WHERE "attendeeType" = 'STUDENT' AND "studentId" IS NOT NULL AND "studentId" NOT IN (SELECT id FROM "Student")
    `;
    console.log(`- Orphaned student attendance records: ${orphanedStudents[0]?.count || 0}`);

    const orphanedTeachers = await prisma.$queryRaw`
      SELECT COUNT(*) as count 
      FROM "AttendanceRecord" 
      WHERE "attendeeType" = 'TEACHER' AND "teacherId" IS NOT NULL AND "teacherId" NOT IN (SELECT id FROM "Teacher")
    `;
    console.log(`- Orphaned teacher attendance records: ${orphanedTeachers[0]?.count || 0}`);

    // 4. Duplicate attendance check (student + date)
    console.log('\nChecking for duplicate daily attendance records per student...');
    const duplicateDailyAttendance = await prisma.$queryRaw`
      SELECT "studentId", "date", COUNT(*) as count
      FROM "AttendanceRecord"
      WHERE "attendeeType" = 'STUDENT' AND "studentId" IS NOT NULL
      GROUP BY "studentId", "date"
      HAVING COUNT(*) > 1
    `;
    console.log(`- Duplicate daily attendance records count: ${duplicateDailyAttendance.length}`);
    if (duplicateDailyAttendance.length > 0) {
      console.log(`- Sample duplicates:`, duplicateDailyAttendance.slice(0, 5));
    }

    // 5. Look for mock/fake records
    console.log('\nScanning for potentially fake/mock records in Student table...');
    const mockStudents = await prisma.student.findMany({
      where: {
        OR: [
          { user: { firstName: { contains: 'test', mode: 'insensitive' } } },
          { user: { firstName: { contains: 'mock', mode: 'insensitive' } } },
          { user: { lastName: { contains: 'test', mode: 'insensitive' } } },
          { user: { email: { contains: 'test', mode: 'insensitive' } } }
        ]
      },
      select: {
        id: true,
        admissionNumber: true,
        user: { select: { firstName: true, lastName: true, email: true } }
      }
    });
    console.log(`- Found ${mockStudents.length} potential mock/test students.`);
    if (mockStudents.length > 0) {
      console.log(`- Sample mock students:`, mockStudents.slice(0, 5));
    }

  } catch (error) {
    console.error('Audit failed with error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

runAudit();
