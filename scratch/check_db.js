const prisma = require('../server/src/config/database');

async function main() {
  console.log("=== Checking Service Requests ===");
  const serviceRequests = await prisma.serviceRequest.findMany({
    orderBy: { createdAt: 'desc' }
  });
  console.log("Service Requests count:", serviceRequests.length);
  if (serviceRequests.length > 0) {
    console.log("Latest Service Request:", JSON.stringify(serviceRequests[0], null, 2));
  }

  console.log("\n=== Checking Stock Movements ===");
  const movements = await prisma.stockMovement.findMany({
    include: { item: true },
    orderBy: { createdAt: 'desc' }
  });
  console.log("Stock Movements count:", movements.length);
  if (movements.length > 0) {
    console.log("Latest Stock Movement:", JSON.stringify(movements[0], null, 2));
  }

  console.log("\n=== Checking Inventory Items ===");
  const items = await prisma.inventoryItem.findMany();
  console.log("Inventory Items count:", items.length);
  if (items.length > 0) {
    console.log("Latest Inventory Item:", JSON.stringify(items[0], null, 2));
  }
}

main()
  .catch(e => console.error("Error running script:", e))
  .finally(() => prisma.$disconnect());
