require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const students = await prisma.studentProfile.findMany({
    where: {
      currentClass: {
        name: {
          in: ['Class 8', 'Class 9', 'Class 10']
        }
      }
    },
    include: {
      user: true,
      currentClass: true,
      section: true
    },
    take: 5
  });

  console.log(`Found ${students.length} students in Classes 8/9/10:`);
  students.forEach(s => {
    console.log(`- Profile ID: ${s.id}`);
    console.log(`  Name: ${s.user.firstName} ${s.user.lastName}`);
    console.log(`  Email: ${s.user.email}`);
    console.log(`  Class: ${s.currentClass.name} | Section: ${s.section ? s.section.name : 'None'}`);
  });
}

main()
  .catch(e => {
    console.error(e);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
