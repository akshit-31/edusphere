import urllib.request
import json
import pprint

def main():
    base_url = "https://edusphere-erp-frontend.onrender.com/api/v1"
    login_url = f"{base_url}/auth/login"
    login_data = json.dumps({
        "email": "student1@edusphere.com",
        "password": "Password@123"
    }).encode('utf-8')

    print(f"Logging in to {login_url}...")
    try:
        req = urllib.request.Request(
            login_url, 
            data=login_data, 
            headers={'Content-Type': 'application/json', 'User-Agent': 'Mozilla/5.0'}
        )
        with urllib.request.urlopen(req, timeout=30) as res:
            login_res = json.loads(res.read().decode('utf-8'))
            print("Login response:")
            pprint.pprint(login_res)
            
            token = login_res.get('token')
            user = login_res.get('user', {})
            student = user.get('student') or {}
            student_id = student.get('id')
            
            print(f"Token: {token}")
            print(f"StudentID from Login response: {student_id}")

            if token:
                # 2. Call students/me
                me_url = f"{base_url}/students/me"
                print(f"Calling students/me: {me_url}...")
                me_req = urllib.request.Request(
                    me_url,
                    headers={
                        'Authorization': f'Bearer {token}',
                        'User-Agent': 'Mozilla/5.0'
                    }
                )
                try:
                    with urllib.request.urlopen(me_req, timeout=30) as me_res:
                        me_data = json.loads(me_res.read().decode('utf-8'))
                        print("students/me response:")
                        pprint.pprint(me_data)
                        
                        student_from_me = me_data.get('student') or {}
                        student_id = student_from_me.get('id') or student_id
                        print(f"StudentID from /students/me: {student_id}")
                except Exception as me_err:
                    print("Error calling students/me:", me_err)

            if token and student_id:
                # 3. Call attendance API
                att_url = f"{base_url}/students/{student_id}/attendance"
                print(f"Calling attendance API: {att_url}...")
                att_req = urllib.request.Request(
                    att_url, 
                    headers={
                        'Authorization': f'Bearer {token}',
                        'User-Agent': 'Mozilla/5.0'
                    }
                )
                with urllib.request.urlopen(att_req, timeout=30) as att_res:
                    att_data = json.loads(att_res.read().decode('utf-8'))
                    print("Attendance API response:")
                    pprint.pprint(att_data)
                
    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    main()
