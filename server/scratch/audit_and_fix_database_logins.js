require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const prisma = new PrismaClient();

async function main() {
  const standardPassword = 'School123!';
  const customPassword = 'Password@123';
  
  const standardHash = await bcrypt.hash(standardPassword, 10);
  const customHash = await bcrypt.hash(customPassword, 10);

  console.log('--- Database User & Profile Login Audit ---');

  // Fetch all users
  const users = await prisma.user.findMany({
    include: {
      teacher: true,
      student: true,
      parent: true,
      staff: true
    }
  });

  console.log(`Total users found in database: ${users.length}`);

  // Fetch default academic year, class, and section for student profile mapping
  const academicYear = await prisma.academicYear.findFirst({
    where: { isCurrent: true }
  }) || await prisma.academicYear.findFirst();

  if (!academicYear) {
    console.error('❌ Error: No AcademicYear found in the database. Please seed or create one first.');
    return;
  }
  console.log(`Using Academic Year: ${academicYear.name} (${academicYear.id})`);

  const class8 = await prisma.class.findFirst({
    where: { name: 'Class 8' }
  }) || await prisma.class.findFirst();

  if (!class8) {
    console.error('❌ Error: No Class found in the database. Please seed or create classes first.');
    return;
  }
  console.log(`Using Default Class: ${class8.name} (${class8.id})`);

  const sectionA = await prisma.section.findFirst({
    where: { classId: class8.id, name: 'A' }
  }) || await prisma.section.findFirst({
    where: { classId: class8.id }
  }) || await prisma.section.findFirst();

  if (!sectionA) {
    console.error('❌ Error: No Section found in the database. Please seed or create sections first.');
    return;
  }
  console.log(`Using Default Section: ${sectionA.name} (${sectionA.id})`);

  let fixCount = 0;
  let passwordResetCount = 0;

  for (const user of users) {
    const isCustomUser = user.email === 'teacher1@edusphere.com' || user.email === 'student1@edusphere.com';
    const targetHash = isCustomUser ? customHash : standardHash;

    // 1. Audit and Fix Password
    await prisma.user.update({
      where: { id: user.id },
      data: { password: targetHash }
    });
    passwordResetCount++;

    // 2. Audit and Fix Profiles based on Role
    if (user.role === 'TEACHER' && !user.teacher) {
      console.log(`🔧 User ${user.email} (TEACHER) is missing a Teacher profile. Creating...`);
      const empId = `EMP-T-${user.firstName.toUpperCase().substring(0, 3)}-${Math.floor(1000 + Math.random() * 9000)}`;
      await prisma.teacher.create({
        data: {
          userId: user.id,
          employeeId: empId,
          qualification: 'B.Ed, Master Degree',
          specialization: 'Academics',
          joiningDate: new Date(),
          status: 'ACTIVE'
        }
      });
      fixCount++;
    } 
    
    else if (user.role === 'STUDENT' && !user.student) {
      console.log(`🔧 User ${user.email} (STUDENT) is missing a StudentProfile. Creating...`);
      const admNum = `ADM${Math.floor(240000 + Math.random() * 9999)}`;
      await prisma.studentProfile.create({
        data: {
          userId: user.id,
          admissionNumber: admNum,
          rollNumber: `${Math.floor(1 + Math.random() * 40)}`,
          joiningDate: new Date(),
          currentClassId: class8.id,
          sectionId: sectionA.id,
          academicYearId: academicYear.id,
          status: 'ACTIVE'
        }
      });
      fixCount++;
    }

    else if (user.role === 'PARENT' && !user.parent) {
      console.log(`🔧 User ${user.email} (PARENT) is missing a ParentProfile. Creating...`);
      await prisma.parentProfile.create({
        data: {
          userId: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          occupation: 'Professional'
        }
      });
      fixCount++;
    }

    else if (user.role === 'STAFF' && !user.staff) {
      console.log(`🔧 User ${user.email} (STAFF) is missing a Staff profile. Creating...`);
      const empId = `EMP-S-${user.firstName.toUpperCase().substring(0, 3)}-${Math.floor(1000 + Math.random() * 9000)}`;
      await prisma.staff.create({
        data: {
          userId: user.id,
          employeeId: empId,
          joiningDate: new Date(),
          department: 'Administration',
          designation: 'Staff Member',
          status: 'ACTIVE'
        }
      });
      fixCount++;
    }
  }

  console.log('\n--- Audit Complete ---');
  console.log(`✅ Reset password hashes for ${passwordResetCount} users.`);
  console.log(`✅ Created missing profiles for ${fixCount} accounts.`);
  console.log('🎉 Every database user is now guaranteed to have a valid profile and password hash!');
}

main()
  .catch(e => {
    console.error('❌ Audit script failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
