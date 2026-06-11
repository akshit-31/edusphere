import requests
import json

BASE = "https://edusphere-erp.onrender.com/api/v1"
token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImI2OGU3NDcyLWQ2ZjQtNGYxMy1iNjEwLWI5YzQwOWY1OTQ4MyIsImVtYWlsIjoidGVhY2hlcjFAZWR1c3BoZXJlLmNvbSIsInJvbGUiOiJURUFDSEVSIiwiaWF0IjoxNzgxMTU1Njg5LCJleHAiOjE3ODEyNDIwODl9.hWpH48FHQ-gu2DPVr_zSCjWJZoNfH7vKWdKUxa4csQw"

headers = {"Authorization": f"Bearer {token}"}
student_id = "2171b290-bccc-4a81-95eb-b857cf81f3ed"

endpoints = [
    f"students/{student_id}/transport-allocation",
    f"students/{student_id}/transportAllocation",
    f"students/{student_id}/route",
]

for ep in endpoints:
    r = requests.get(f"{BASE}/{ep}", headers=headers)
    print(f"GET /{ep} Status: {r.status_code}")
    if r.status_code == 200:
        print("Response:", r.json())
        break
