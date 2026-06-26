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
        with urllib.request.urlopen(req, timeout=30) as res:
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
        with urllib.request.urlopen(req, timeout=30) as res:
            return json.loads(res.read().decode('utf-8'))
    except Exception as e:
        print(f"REST API Error on {method} {url}: {e}")
        return None

def main():
    base_url = "https://edusphere-erp-frontend.onrender.com/api/v1"
    today_str = datetime.utcnow().strftime("%Y-%m-%d")
    print(f"Target Date for Audit Test: {today_str}")

    # 1. Student login & fetch details
    print("\n--- Step 1: Student Login & Profile Resolve ---")
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

    # 2. Check current status for today in Supabase
    print("\n--- Step 2: Fetch current status from Supabase ---")
    existing_records = sb_request(f"AttendanceRecord?studentId=eq.{student_id}&date=eq.{today_str}")
    
    # Let's decide target status
    target_status = "ABSENT"
    record_id = None
    
    if existing_records:
        rec = existing_records[0]
        record_id = rec.get('id')
        current_status = rec.get('status')
        print(f"Found existing record. ID: {record_id} | Current Status: {current_status}")
        if current_status == "ABSENT":
            target_status = "PRESENT"
    else:
        print("No record found. We will insert one.")

    # 3. Create or update record in Supabase
    print(f"\n--- Step 3: Set status to '{target_status}' ---")
    if record_id:
        # Update
        updated = sb_request(f"AttendanceRecord?id=eq.{record_id}", method='PATCH', data={"status": target_status, "updatedAt": datetime.utcnow().isoformat() + "Z"})
        if updated:
            print("PASS: Record updated successfully in Supabase.")
        else:
            print("FAIL: Failed to update record in Supabase.")
            return
    else:
        # Insert
        new_record_data = {
            "attendeeType": "STUDENT",
            "studentId": student_id,
            "date": today_str,
            "status": target_status,
            "scannedByRFID": False,
            "scannedByQR": False,
            "updatedAt": datetime.utcnow().isoformat() + "Z"
        }
        inserted = sb_request("AttendanceRecord", method='POST', data=new_record_data)
        if inserted:
            print("PASS: Record inserted successfully in Supabase.")
        else:
            print("FAIL: Failed to insert record in Supabase.")
            return

    # 4. Query student REST API to verify it instantly displays the new status
    print("\n--- Step 4: Verify status instantly reflects in Student REST API ---")
    student_att = api_request(f"{base_url}/students/{student_id}/attendance", token=student_token)
    if student_att and student_att.get('success'):
        records = student_att.get('attendance', [])
        # Find today's record
        today_record = next((r for r in records if r.get('date').startswith(today_str)), None)
        if today_record:
            print("PASS: Today's attendance record found in student REST API response!")
            print(f"  Status in API: {today_record.get('status')} (Expected: {target_status})")
            if today_record.get('status') == target_status:
                print("PASS: API status matches expected target status exactly!")
            else:
                print("FAIL: API status mismatch!")
        else:
            print("FAIL: Today's record was not found in student REST API response")
    else:
        print("FAIL: Student REST API request failed")

if __name__ == "__main__":
    main()
