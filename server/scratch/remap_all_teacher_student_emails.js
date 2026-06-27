require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const prisma = new PrismaClient();

async function main() {
  const plainPassword = 'Password@123';
  const passwordHash = await bcrypt.hash(plainPassword, 10);

  console.log('--- Remapping Database User Emails sequentially ---');

  // 1. Fetch all teachers and students
  const teachers = await prisma.user.findMany({
    where: { role: 'TEACHER' },
    orderBy: { createdAt: 'asc' }
  });

  const students = await prisma.user.findMany({
    where: { role: 'STUDENT' },
    orderBy: { createdAt: 'asc' }
  });

  console.log(`Found ${teachers.length} teachers and ${students.length} students in the database.`);

  // PHASE A: Rename to temp emails to prevent unique constraint failures
  console.log('\nPhase A: Renaming to temporary emails...');
  
  for (let i = 0; i < teachers.length; i++) {
    await prisma.user.update({
      where: { id: teachers[i].id },
      data: { email: `temp_teacher_${i + 1}@temp.com` }
    });
  }
  console.log(`✅ Moved ${teachers.length} teachers to temporary emails.`);

  for (let i = 0; i < students.length; i++) {
    await prisma.user.update({
      where: { id: students[i].id },
      data: { email: `temp_student_${i + 1}@temp.com` }
    });
  }
  console.log(`✅ Moved ${students.length} students to temporary emails.`);

  // PHASE B: Rename to final edusphere.com emails and set password
  console.log('\nPhase B: Renaming to final sequential edusphere.com emails...');

  for (let i = 0; i < teachers.length; i++) {
    const finalEmail = `teacher${i + 1}@edusphere.com`;
    await prisma.user.update({
      where: { id: teachers[i].id },
      data: { 
        email: finalEmail,
        password: passwordHash
      }
    });
    console.log(`  - Teacher ID: ${teachers[i].id} -> ${finalEmail}`);
  }
  console.log(`✅ Successfully mapped all ${teachers.length} teachers.`);

  for (let i = 0; i < students.length; i++) {
    const finalEmail = `student${i + 1}@edusphere.com`;
    await prisma.user.update({
      where: { id: students[i].id },
      data: { 
        email: finalEmail,
        password: passwordHash
      }
    });
    console.log(`  - Student ID: ${students[i].id} -> ${finalEmail}`);
  }
  console.log(`✅ Successfully mapped all ${students.length} students.`);

  console.log('\n🎉 ALL CREDS REMAPPED SUCCESSFULLY!');
  console.log(`Every Teacher can now login with: teacherX@edusphere.com / ${plainPassword}`);
  console.log(`Every Student can now login with: studentY@edusphere.com / ${plainPassword}`);
}

main()
  .catch(e => {
    console.error('❌ Remapping script failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
