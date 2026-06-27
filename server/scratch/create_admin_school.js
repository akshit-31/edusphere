const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const prisma = new PrismaClient();

async function main() {
  const email = 'admin@school.com';
  const plainPassword = 'School123!';
  const passwordHash = await bcrypt.hash(plainPassword, 10);

  console.log(`Checking if user ${email} exists...`);
  const existingUser = await prisma.user.findUnique({
    where: { email }
  });

  if (existingUser) {
    console.log(`User ${email} exists. Updating password, role, and active status...`);
    const updated = await prisma.user.update({
      where: { email },
      data: {
        password: passwordHash,
        role: 'ADMIN',
        roles: ['ADMIN'],
        isActive: true
      }
    });
    console.log('User updated successfully:', updated.id);
  } else {
    console.log(`User ${email} does not exist. Creating user...`);
    const created = await prisma.user.create({
      data: {
        email,
        password: passwordHash,
        firstName: 'System',
        lastName: 'Administrator',
        role: 'ADMIN',
        roles: ['ADMIN'],
        isActive: true
      }
    });
    console.log('User created successfully:', created.id);
  }
}

main()
  .catch(e => {
    console.error('Error executing script:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
