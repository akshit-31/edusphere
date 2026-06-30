const prisma = require('./src/config/database');

async function main() {
  try {
    const teachers = await prisma.teacher.findMany({
      where: {
        id: { in: ['b2762064-2986-4c4a-b3e1-5e4d638144f4', '750fe67b-7f92-4a23-afe6-26e9c0b9ec9c'] }
      },
      include: { user: true }
    });
    console.log('Teachers with assignments:');
    teachers.forEach(t => {
      console.log(`- ${t.user.firstName} ${t.user.lastName}: ${t.user.email} (Teacher ID: ${t.id})`);
    });
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await prisma.$disconnect();
  }
}

main();
