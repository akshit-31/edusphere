const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const teacher = await prisma.teacher.findFirst({
    where: {
      user: {
        firstName: { contains: 'Karan', mode: 'insensitive' }
      }
    },
    include: {
      user: true,
      subjects: {
        include: {
          subject: {
            include: {
              class: true
            }
          }
        }
      }
    }
  });

  if (!teacher) {
    console.log("Teacher Karan not found");
    return;
  }

  console.log(`Teacher: ${teacher.user.firstName} ${teacher.user.lastName} | ID=${teacher.id}`);
  console.log(`Class Teacher of: ${teacher.assignedClassId || 'None'}`);
  console.log("Subjects Taught:");
  for (const s of teacher.subjects) {
    console.log(`  Subject: ID=${s.subject.id} | Name=${s.subject.name} | Class=${s.subject.class?.name}`);
  }
  
  await prisma.$disconnect();
}

main();
