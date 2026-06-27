const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log("=== CLASSES & SECTIONS ===");
  const classes = await prisma.class.findMany({
    include: {
      sections: {
        include: {
          _count: {
            select: { students: true }
          }
        }
      },
      classTeacher: {
        include: { user: true }
      }
    }
  });

  for (const c of classes) {
    console.log(`Class: ${c.name} (ID: ${c.id})`);
    console.log(`  Class Teacher: ${c.classTeacher ? `${c.classTeacher.user.firstName} ${c.classTeacher.user.lastName}` : 'None'}`);
    for (const sec of c.sections) {
      console.log(`    Section: ${sec.name} (ID: ${sec.id}) | Students count: ${sec._count.students}`);
    }
  }

  console.log("\n=== ALL TEACHERS ===");
  const teachers = await prisma.teacher.findMany({
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

  for (const t of teachers) {
    console.log(`Teacher: ${t.user.firstName} ${t.user.lastName} | ID: ${t.id} | Email: ${t.user.email} | Role: ${t.user.role}`);
    for (const s of t.subjects) {
      console.log(`  Teaches: ${s.subject.name} in Class ${s.subject.class?.name || 'unknown'}`);
    }
  }

  console.log("\n=== SAMPLE STUDENTS ===");
  const students = await prisma.studentProfile.findMany({
    take: 5,
    include: {
      user: true,
      currentClass: true,
      section: true
    }
  });

  for (const s of students) {
    console.log(`Student: ${s.user.firstName} ${s.user.lastName} | Class: ${s.currentClass?.name} | Section: ${s.section?.name}`);
  }

  await prisma.$disconnect();
}

main().catch(console.error);
