import urllib.request
import json
import pprint
from datetime import datetime

# Supabase details
SB_URL = "https://bstevdkjqjzaglayicdg.supabase.co/rest/v1"
SB_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE"

def get_sb_headers():
    return {
        "apikey": SB_KEY,
        "Authorization": f"Bearer {SB_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=representation"
    }

def sb_request(path, method='GET', data=None):
    url = f"{SB_URL}/{path}"
    try:
        encoded_data = json.dumps(data).encode('utf-8') if data else None
        req = urllib.request.Request(
            url,
            data=encoded_data,
            headers=get_sb_headers(),
            method=method
        )
        with urllib.request.urlopen(req, timeout=15) as res:
            return json.loads(res.read().decode('utf-8'))
    except Exception as e:
        print(f"Supabase Error on {method} {path}: {e}")
        return None

def api_request(url, method='GET', data=None, token=None):
    try:
        encoded_data = json.dumps(data).encode('utf-8') if data else None
        headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'Mozilla/5.0'
        }
        if token:
            headers['Authorization'] = f'Bearer {token}'
        req = urllib.request.Request(
            url,
            data=encoded_data,
            headers=headers,
            method=method
        )
        with urllib.request.urlopen(req, timeout=15) as res:
            return json.loads(res.read().decode('utf-8'))
    except Exception as e:
        print(f"REST API Error on {method} {url}: {e}")
        return None

def main():
    base_url = "https://edusphere-erp-frontend.onrender.com/api/v1"
    today_str = datetime.utcnow().strftime("%Y-%m-%d")
    print(f"Target Date for Audit Test: {today_str}")

    # 1. Teacher login simulation
    print("\n--- Step 1: Teacher Login ---")
    teacher_login = api_request(
        f"{base_url}/auth/login", 
        method='POST',
        data={"email": "teacher1@edusphere.com", "password": "Password@123"}
    )
    if not teacher_login or not teacher_login.get('success'):
        print("FAIL: Teacher login failed")
        return
    print("PASS: Teacher logged in successfully.")

    # 2. Student login & fetch details
    print("\n--- Step 2: Student Login & Profile Resolve ---")
    student_login = api_request(
        f"{base_url}/auth/login",
        method='POST',
        data={"email": "student1@edusphere.com", "password": "Password@123"}
    )
    if not student_login or not student_login.get('success'):
        print("FAIL: Student login failed")
        return
    student_token = student_login.get('token')
    
    # Fetch student profile via students/me
    student_me = api_request(f"{base_url}/students/me", token=student_token)
    if not student_me or not student_me.get('success'):
        print("FAIL: Failed to fetch student profile")
        return
    student_profile = student_me.get('student', {})
    student_id = student_profile.get('id')
    student_name = f"{student_profile.get('user', {}).get('firstName')} {student_profile.get('user', {}).get('lastName')}"
    print(f"PASS: Resolved student '{student_name}' | ID: {student_id}")

    # 3. Suppress/Clean any existing record for today in Supabase for a clean test
    print("\n--- Step 3: Clear any existing attendance for today ---")
    existing_records = sb_request(f"AttendanceRecord?studentId=eq.{student_id}&date=eq.{today_str}")
    if existing_records:
        print(f"Found existing record for today: {existing_records[0].get('id')}. Deleting it...")
        sb_request(f"AttendanceRecord?id=eq.{existing_records[0].get('id')}", method='DELETE')
        print("Existing record cleared.")
    else:
        print("No existing attendance record for today. Ready for fresh test.")

    # 4. Mark student attendance as PRESENT for today (simulating Teacher panel submit)
    print("\n--- Step 4: Teacher marks Student as PRESENT ---")
    new_record_data = {
        "attendeeType": "STUDENT",
        "studentId": student_id,
        "date": today_str,
        "status": "PRESENT",
        "scannedByRFID": False,
        "scannedByQR": False,
        "updatedAt": datetime.utcnow().isoformat() + "Z"
    }
    inserted = sb_request("AttendanceRecord", method='POST', data=new_record_data)
    if not inserted:
        print("FAIL: Failed to insert new attendance record in Supabase")
        return
    record_id = inserted[0].get('id')
    print(f"PASS: Created AttendanceRecord in Supabase | ID: {record_id}")

    # 5. Database check
    print("\n--- Step 5: Database Consistency Check ---")
    db_check = sb_request(f"AttendanceRecord?id=eq.{record_id}")
    if db_check and len(db_check) > 0:
        rec = db_check[0]
        print(f"PASS: Database record verified:")
        print(f"  ID: {rec.get('id')}")
        print(f"  studentId: {rec.get('studentId')}")
        print(f"  date: {rec.get('date')}")
        print(f"  status: {rec.get('status')}")
    else:
        print("FAIL: Database record not found on verification check")
        return

    # 6. Student mobile login & open attendance page simulation
    print("\n--- Step 6: Student retrieves attendance via REST API ---")
    student_att = api_request(f"{base_url}/students/{student_id}/attendance", token=student_token)
    if student_att and student_att.get('success'):
        records = student_att.get('attendance', [])
        # Find today's record
        today_record = next((r for r in records if r.get('date').startswith(today_str)), None)
        if today_record:
            print("PASS: Today's attendance record found in student REST API response!")
            print(f"  Status: {today_record.get('status')}")
            print(f"  Marked By: {today_record.get('markedBy') or 'System/QR'}")
        else:
            print("FAIL: Today's record was not found in student REST API response")
    else:
        print("FAIL: Student REST API request failed")

if __name__ == "__main__":
    main()
