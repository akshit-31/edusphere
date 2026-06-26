import urllib.request
import json
import pprint

def get_post_headers(token=None):
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0'
    }
    if token:
        headers['Authorization'] = f'Bearer {token}'
    return headers

def api_request(url, method='GET', data=None, token=None):
    try:
        encoded_data = json.dumps(data).encode('utf-8') if data else None
        req = urllib.request.Request(
            url,
            data=encoded_data,
            headers=get_post_headers(token),
            method=method
        )
        with urllib.request.urlopen(req, timeout=30) as res:
            return json.loads(res.read().decode('utf-8'))
    except Exception as e:
        print(f"Error on {method} {url}: {e}")
        return None

def main():
    base_url = "https://edusphere-erp-frontend.onrender.com/api/v1"
    
    # 1. Login Teacher
    print("--- 1. Login Teacher1 ---")
    teacher_login = api_request(
        f"{base_url}/auth/login", 
        method='POST',
        data={"email": "teacher1@edusphere.com", "password": "Password@123"}
    )
    if teacher_login and teacher_login.get('success'):
        teacher_token = teacher_login.get('token')
        teacher_user = teacher_login.get('user', {})
        teacher_profile = teacher_user.get('teacher') or {}
        print(f"Teacher User ID: {teacher_user.get('id')}")
        print(f"Teacher Profile ID: {teacher_profile.get('id')}")
        print(f"Teacher Name: {teacher_user.get('firstName')} {teacher_user.get('lastName')}")
    else:
        print("Teacher login failed!")
        teacher_token = None

    # 2. Login Student
    print("\n--- 2. Login Student1 ---")
    student_login = api_request(
        f"{base_url}/auth/login",
        method='POST',
        data={"email": "student1@edusphere.com", "password": "Password@123"}
    )
    if student_login and student_login.get('success'):
        student_token = student_login.get('token')
        student_user = student_login.get('user', {})
        student_profile = student_user.get('student') or {}
        student_id = student_profile.get('id')
        print(f"Student User ID: {student_user.get('id')}")
        print(f"Student Profile ID: {student_id}")
        print(f"Student Class ID: {student_profile.get('currentClassId')}")
        print(f"Student Section ID: {student_profile.get('sectionId')}")
        print(f"Student Name: {student_user.get('firstName')} {student_user.get('lastName')}")
    else:
        print("Student login failed!")
        student_token = None
        student_id = None

    if student_token and student_id:
        # 3. Fetch Student Attendance Records
        print(f"\n--- 3. Fetching Attendance for Student Profile ID {student_id} ---")
        attendance_res = api_request(
            f"{base_url}/students/{student_id}/attendance",
            token=student_token
        )
        if attendance_res and attendance_res.get('success'):
            records = attendance_res.get('attendance', [])
            print(f"Total Attendance Records found: {len(records)}")
            if records:
                print("First 3 records:")
                pprint.pprint(records[:3])
        else:
            print("Failed to fetch student attendance from API!")

if __name__ == "__main__":
    main()
