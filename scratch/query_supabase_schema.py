import requests
import json

URL = "https://bstevdkjqjzaglayicdg.supabase.co/rest/v1"
KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE"

headers = {
    "apikey": KEY,
    "Authorization": f"Bearer {KEY}",
}

r = requests.get(f"{URL}/Student", headers=headers, params={
    "select": "id,admissionNumber,User:User(firstName,lastName,email)",
    "limit": 1000
})
students = r.json()
print(f"Total students in DB: {len(students)}")
for s in students:
    adm = s.get('admissionNumber', '')
    user = s.get('User') or {}
    name = f"{user.get('firstName', '')} {user.get('lastName', '')}"
    email = user.get('email', '')
    if 'adm' in adm.lower() or 'saanvi' in name.lower() or 'kavita' in name.lower():
        print(f"  {adm} | {name} | {email} | {s['id']}")
