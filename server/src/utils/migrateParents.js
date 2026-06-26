require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const prisma = require('../config/database');
const bcrypt = require('bcrypt');

async function migrateParents() {
  console.log('🔄 Starting Parent Profile migration...');
  
  // Find all parent profiles that do not have a userId
  const parents = await prisma.parentProfile.findMany({
    where: { userId: null }
  });

  console.log(`Found ${parents.length} parents without a User account.`);

  let migratedCount = 0;
  const defaultPasswordHash = await bcrypt.hash('Parent123!', 10);

  for (const parent of parents) {
    try {
      // Create a unique email if the parent doesn't have one
      const email = parent.email || `${parent.phone || parent.id}@edusphere-parent.com`;
      
      // Check if user already exists with this email
      let user = await prisma.user.findUnique({
        where: { email }
      });

      if (!user) {
        // Create new User account
        user = await prisma.user.create({
          data: {
            email,
            password: defaultPasswordHash,
            firstName: parent.firstName,
            lastName: parent.lastName,
            phone: parent.phone,
            role: 'PARENT',
            roles: ['PARENT'],
          }
        });
        console.log(`Created User account for parent ${parent.firstName} ${parent.lastName} (${email})`);
      } else {
        console.log(`User account already exists for email ${email}, linking...`);
      }

      // Link Parent to User
      await prisma.parentProfile.update({
        where: { id: parent.id },
        data: { userId: user.id }
      });

      migratedCount++;
    } catch (err) {
      console.error(`Failed to migrate parent ${parent.firstName} ${parent.lastName}:`, err.message);
    }
  }

  console.log(`\n🎉 Migrated ${migratedCount} parents successfully.`);
}

module.exports = migrateParents;

if (require.main === module) {
  migrateParents()
    .catch(console.error)
    .finally(() => prisma.$disconnect());
}
