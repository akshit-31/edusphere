const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log("Querying database via Prisma...");
  try {
    const classes = await prisma.class.findMany({
      include: {
        sections: true,
        classTeacher: {
          include: { user: true }
        }
      }
    });
    
    console.log("\n--- Classes ---");
    for (const c of classes) {
      console.log(`Class: ID=${c.id}, Name=${c.name}, Teacher=${c.classTeacher ? c.classTeacher.user.firstName + ' ' + c.classTeacher.user.lastName : 'None'}`);
      for (const s of c.sections) {
        console.log(`  Section: ID=${s.id}, Name=${s.name}`);
      }
    }
    
    const teachers = await prisma.teacher.findMany({
      include: { user: true }
    });
    
    console.log("\n--- Teachers ---");
    for (const t of teachers) {
      console.log(`Teacher: ID=${t.id}, Email=${t.user.email}, Name=${t.user.firstName} ${t.user.lastName}`);
    }
  } catch (err) {
    console.error("Error:", err);
  } finally {
    await prisma.$disconnect();
  }
}

main();
