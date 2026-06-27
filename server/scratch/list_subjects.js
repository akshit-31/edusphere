const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const classes = await prisma.class.findMany({
    where: {
      name: { in: ['Class 8', 'Class 9', 'Class 10'] }
    },
    include: {
      subjects: true
    }
  });

  for (const c of classes) {
    console.log(`Class: ${c.name} (ID: ${c.id})`);
    for (const sub of c.subjects) {
      console.log(`  Subject: ${sub.name} (ID: ${sub.id}) | Code: ${sub.code}`);
    }
  }

  await prisma.$disconnect();
}

main().catch(console.error);
