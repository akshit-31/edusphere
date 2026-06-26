import urllib.request
import json
import pprint

def main():
    base_url = "https://edusphere-erp-frontend.onrender.com/api/v1"
    
    # Login Student
    student_login = json.loads(urllib.request.urlopen(
        urllib.request.Request(
            f"{base_url}/auth/login",
            data=json.dumps({"email": "student1@edusphere.com", "password": "Password@123"}).encode('utf-8'),
            headers={'Content-Type': 'application/json'}
        )
    ).read().decode('utf-8'))
    
    token = student_login['token']
    student_id = student_login['user']['student']['id'] if student_login['user'].get('student') else '2171b290-bccc-4a81-95eb-b857cf81f3ed'
    
    # Fetch student/me to verify ID
    me_req = urllib.request.Request(
        f"{base_url}/students/me",
        headers={'Authorization': f'Bearer {token}'}
    )
    me_data = json.loads(urllib.request.urlopen(me_req).read().decode('utf-8'))
    student_id = me_data['student']['id']
    
    # Query attendance via REST API
    att_req = urllib.request.Request(
        f"{base_url}/students/{student_id}/attendance",
        headers={'Authorization': f'Bearer {token}'}
    )
    att_data = json.loads(urllib.request.urlopen(att_req).read().decode('utf-8'))
    
    print(f"Attendance for Student ID: {student_id}")
    pprint.pprint(att_data)

if __name__ == "__main__":
    main()
