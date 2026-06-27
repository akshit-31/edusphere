async function main() {
  const email = 'teacher1@edusphere.com';
  const password = 'Password@123';
  const baseUrl = 'https://edusphere-erp-frontend.onrender.com/api/v1';

  console.log("Logging in...");
  const loginRes = await fetch(`${baseUrl}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  });

  const loginData = await loginRes.json();
  const token = loginData.token;
  console.log("Logged in! Token obtained.");

  const headers = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  };

  // Get items to get a valid itemId
  console.log("\nFetching inventory items...");
  const itemsRes = await fetch(`${baseUrl}/inventory/items`, { headers });
  const itemsData = await itemsRes.json();
  const items = itemsData.data || [];
  console.log(`Found ${items.length} items.`);
  if (items.length === 0) {
    console.log("No items available to test!");
    return;
  }

  const testItem = items[0];
  console.log("Using test item:", testItem.name, "(ID:", testItem.id, ")");

  // Get requests list to see full fields
  console.log("\nFetching current requests list...");
  const listRes = await fetch(`${baseUrl}/inventory/requests`, { headers });
  const listData = await listRes.json();
  console.log("Current requests count:", listData.data?.length || 0);
  if (listData.data?.length > 0) {
    console.log("Example request structure:", JSON.stringify(listData.data[0], null, 2));
  }

  // Attempt POST to create a request
  const testPayloads = [
    { itemId: testItem.id, quantity: 1, notes: "Test inventory request 1" },
    { inventoryItemId: testItem.id, quantity: 1, notes: "Test inventory request 2" }
  ];

  for (const payload of testPayloads) {
    console.log("\nAttempting POST to /inventory/requests with payload:", payload);
    try {
      const postRes = await fetch(`${baseUrl}/inventory/requests`, {
        method: 'POST',
        headers,
        body: JSON.stringify(payload)
      });
      console.log("Status:", postRes.status);
      const postData = await postRes.json();
      console.log("Response body:", JSON.stringify(postData, null, 2));
    } catch (err) {
      console.log("Error posting:", err);
    }
  }
}

main().catch(e => console.error("Unhandled error:", e));
