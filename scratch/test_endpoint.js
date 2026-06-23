async function run() {
  const res1 = await fetch("https://edusphere-erp-frontend.onrender.com/api/v1/fees/students/me/status");
  console.log('Status me:', res1.status, await res1.text());

  const res2 = await fetch("https://edusphere-erp-frontend.onrender.com/api/fees/students/me/status");
  console.log('Status Next API:', res2.status, await res2.text());
}
run();
