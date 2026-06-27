const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany({
    where: {
      email: {
        endsWith: '@edusphere.com'
      }
    },
    select: {
      id: true,
      email: true,
      role: true,
      firstName: true,
      lastName: true
    }
  });

  console.log(`Found ${users.length} users ending with @edusphere.com:`);
  users.forEach(u => {
    console.log(`- ID: ${u.id} | Email: ${u.email} | Role: ${u.role} | Name: ${u.firstName} ${u.lastName}`);
  });
}

main()
  .catch(e => {
    console.error(e);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
