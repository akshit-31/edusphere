import requests, json

BASE = "https://edusphere-erp.onrender.com/api/v1"
token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImI2OGU3NDcyLWQ2ZjQtNGYxMy1iNjEwLWI5YzQwOWY1OTQ4MyIsImVtYWlsIjoidGVhY2hlcjFAZWR1c3BoZXJlLmNvbSIsInJvbGUiOiJURUFDSEVSIiwiaWF0IjoxNzgxMTU1Njg5LCJleHAiOjE3ODEyNDIwODl9.hWpH48FHQ-gu2DPVr_zSCjWJZoNfH7vKWdKUxa4csQw"

headers = {"Authorization": f"Bearer {token}"}

for ep in ["dashboard/stats", "teachers/my-classes", "teachers"]:
    r = requests.get(f"{BASE}/{ep}", headers=headers)
    print(f"GET /{ep} Status:", r.status_code)
    try:
        data = r.json()
        print(json.dumps(data, indent=2)[:1200])
    except Exception as e:
        print("  Error/Non-JSON:", e, r.text[:200])
