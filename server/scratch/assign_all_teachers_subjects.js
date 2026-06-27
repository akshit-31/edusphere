const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log("Fetching Class 8, Class 9, Class 10...");
  const classes = await prisma.class.findMany({
    where: {
      name: { in: ['Class 8', 'Class 9', 'Class 10'] }
    },
    include: {
      subjects: {
        where: {
          name: 'Mathematics'
        }
      }
    }
  });

  const subjectIds = [];
  for (const c of classes) {
    console.log(`Class found: ${c.name} (ID: ${c.id})`);
    for (const sub of c.subjects) {
      console.log(`  Subject found: ${sub.name} (ID: ${sub.id})`);
      subjectIds.push(sub.id);
    }
  }

  if (subjectIds.length === 0) {
    console.error("❌ No Mathematics subjects found for Class 8, 9, 10! Please verify database state.");
    await prisma.$disconnect();
    process.exit(1);
  }

  console.log("Fetching all teachers...");
  const teachers = await prisma.teacher.findMany({
    include: {
      user: true
    }
  });
  console.log(`Found ${teachers.length} teachers.`);

  console.log("Assigning subjects to all teachers...");
  let count = 0;
  for (const t of teachers) {
    for (const sId of subjectIds) {
      try {
        await prisma.subjectTeacher.upsert({
          where: {
            subjectId_teacherId: {
              subjectId: sId,
              teacherId: t.id
            }
          },
          create: {
            subjectId: sId,
            teacherId: t.id
          },
          update: {}
        });
        count++;
      } catch (err) {
        console.error(`Error assigning subject ${sId} to teacher ${t.user.email}:`, err);
      }
    }
  }

  console.log(`✅ Completed assigning. Created/updated ${count} teacher-subject links.`);
  await prisma.$disconnect();
}

main().catch(async (e) => {
  console.error(e);
  await prisma.$disconnect();
  process.exit(1);
});
