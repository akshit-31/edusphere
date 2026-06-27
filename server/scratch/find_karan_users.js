const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany({
    where: {
      OR: [
        { firstName: { contains: 'Karan', mode: 'insensitive' } },
        { lastName: { contains: 'Sharma', mode: 'insensitive' } },
        { lastName: { contains: 'Kumar', mode: 'insensitive' } }
      ]
    },
    include: {
      teacher: {
        include: {
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
      },
      student: true
    }
  });

  console.log(`Found ${users.length} users:`);
  for (const u of users) {
    console.log(`User: ${u.firstName} ${u.lastName} | Email: ${u.email} | Role: ${u.role} | Active: ${u.isActive}`);
    if (u.teacher) {
      console.log(`  Teacher profile exists. ID: ${u.teacher.id}`);
      const classTeacherOf = await prisma.class.findMany({
        where: { classTeacherId: u.teacher.id }
      });
      console.log(`  Class Teacher of: ${classTeacherOf.map(c => c.name).join(', ') || 'None'}`);
      console.log(`  Subjects:`);
      for (const s of u.teacher.subjects) {
        console.log(`    - ${s.subject.name} (Class: ${s.subject.class?.name})`);
      }
    }
  }

  await prisma.$disconnect();
}

main().catch(console.error);
