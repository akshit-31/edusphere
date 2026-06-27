const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const prisma = new PrismaClient();

async function main() {
  const plainPassword = 'Password@123';
  const passwordHash = await bcrypt.hash(plainPassword, 10);

  // 1. Update Teacher (Karan Kumar)
  console.log('Finding user associated with Teacher profile 3eaf61d1-6f02-4486-b5b4-3c5fad23b424 (Karan Kumar)...');
  const teacherProfile = await prisma.teacher.findUnique({
    where: { id: '3eaf61d1-6f02-4486-b5b4-3c5fad23b424' },
    include: { user: true }
  });

  if (teacherProfile && teacherProfile.user) {
    const updatedTeacherUser = await prisma.user.update({
      where: { id: teacherProfile.userId },
      data: {
        email: 'teacher1@edusphere.com',
        password: passwordHash
      }
    });
    console.log(`✅ Teacher Karan Kumar user account updated:`);
    console.log(`   Email: ${updatedTeacherUser.email}`);
    console.log(`   New Password Set: ${plainPassword}`);
  } else {
    console.error('❌ Could not find teacher profile or user for Karan Kumar.');
  }

  // 2. Update Student (Arjun Kumar - Class 8 Section A)
  console.log('\nFinding user associated with Student profile 04aa9430-8832-4297-bbf3-c2d6112b70af (Arjun Kumar)...');
  const studentProfile = await prisma.studentProfile.findUnique({
    where: { id: '04aa9430-8832-4297-bbf3-c2d6112b70af' },
    include: { user: true }
  });

  if (studentProfile && studentProfile.user) {
    const updatedStudentUser = await prisma.user.update({
      where: { id: studentProfile.userId },
      data: {
        email: 'student1@edusphere.com',
        password: passwordHash
      }
    });
    console.log(`✅ Student Arjun Kumar user account updated:`);
    console.log(`   Email: ${updatedStudentUser.email}`);
    console.log(`   New Password Set: ${plainPassword}`);
  } else {
    console.error('❌ Could not find student profile or user for Arjun Kumar.');
  }
}

main()
  .catch(e => {
    console.error('Error running script:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
