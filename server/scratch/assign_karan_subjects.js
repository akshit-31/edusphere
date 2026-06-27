const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const teacherId = '3eaf61d1-6f02-4486-b5b4-3c5fad23b424'; // Karan Kumar
  const subjectIds = [
    '1617e6a4-f106-488b-be4e-b8aabb40136a', // Math 8
    '6a78993d-54cf-46d5-abe6-f1bc04202518', // Math 9
    '0442661d-ba9f-4bbb-b598-efeec7186681'  // Math 10
  ];

  console.log("Assigning subjects to teacher...");
  for (const sId of subjectIds) {
    try {
      const assignment = await prisma.subjectTeacher.upsert({
        where: {
          subjectId_teacherId: {
            subjectId: sId,
            teacherId: teacherId
          }
        },
        create: {
          subjectId: sId,
          teacherId: teacherId
        },
        update: {}
      });
      console.log(`Assigned subject ${sId} to teacher ${teacherId}`);
    } catch (err) {
      console.error(`Error assigning ${sId}:`, err);
    }
  }

  await prisma.$disconnect();
}

main().catch(console.error);
