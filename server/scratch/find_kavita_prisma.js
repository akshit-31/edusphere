const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany({
    where: {
      firstName: { contains: 'Kavita', mode: 'insensitive' }
    },
    include: {
      student: true
    }
  });

  console.log(`Found ${users.length} users with name Kavita:`);
  users.forEach(u => {
    console.log(`- ID: ${u.id} | Email: ${u.email} | Student Profile: ${u.student ? u.student.id : 'NONE'}`);
  });
}

main()
  .catch(e => {
    console.error(e);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
