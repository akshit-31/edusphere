const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany({
    where: {
      OR: [
        { firstName: { contains: 'Kavita', mode: 'insensitive' } },
        { lastName: { contains: 'Das', mode: 'insensitive' } }
      ]
    },
    include: {
      student: {
        include: {
          currentClass: true,
          section: true
        }
      }
    }
  });

  console.log(`Found ${users.length} matching users`);
  for (const u of users) {
    console.log(`User: ${u.firstName} ${u.lastName} | Email: ${u.email} | Role: ${u.role}`);
    if (u.student) {
      console.log(`  StudentProfile: ID=${u.student.id} | Class=${u.student.currentClass?.name} | Section=${u.student.section?.name}`);
    }
  }
  
  await prisma.$disconnect();
}

main();
