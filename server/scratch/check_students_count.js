const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const classObj = await prisma.class.findFirst({
    where: { name: 'Class 8' }
  });
  if (!classObj) {
    console.log("Class 8 not found");
    return;
  }
  const sectionObj = await prisma.section.findFirst({
    where: { classId: classObj.id, name: 'A' }
  });
  if (!sectionObj) {
    console.log("Section A of Class 8 not found");
    return;
  }

  const students = await prisma.studentProfile.findMany({
    where: {
      currentClassId: classObj.id,
      sectionId: sectionObj.id
    },
    include: {
      user: true
    }
  });

  console.log(`Found ${students.length} students in Class 8 Section A`);
  for (const s of students) {
    console.log(`Student: ${s.user.firstName} ${s.user.lastName} | Admission: ${s.admissionNumber}`);
  }
  
  await prisma.$disconnect();
}

main();
