const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  try {
    const users = await prisma.user.findMany({
      take: 10,
      select: { email: true, role: true }
    });
    console.log('Sample Users:');
    console.log(JSON.stringify(users, null, 2));

    const studentCount = await prisma.student.count();
    const teacherCount = await prisma.teacher.count();
    console.log(`Counts -> Students: ${studentCount}, Teachers: ${teacherCount}`);
  } catch (error) {
    console.error('Error querying users:', error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
