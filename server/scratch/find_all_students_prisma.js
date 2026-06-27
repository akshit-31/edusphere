require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const students = await prisma.studentProfile.findMany({
    include: {
      user: true
    },
    take: 10
  });

  console.log(`Found ${students.length} students in active database:`);
  students.forEach(s => {
    console.log(`- Profile ID: ${s.id} | Admission No: ${s.admissionNumber} | Name: ${s.user.firstName} ${s.user.lastName} | Email: ${s.user.email}`);
  });
}

main()
  .catch(e => {
    console.error(e);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
