import urllib.request
import json
import pprint

# Supabase details
SB_URL = "https://bstevdkjqjzaglayicdg.supabase.co/rest/v1"
SB_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE"

def main():
    url = f"{SB_URL}/AttendanceRecord?limit=5"
    req = urllib.request.Request(
        url,
        headers={
            "apikey": SB_KEY,
            "Authorization": f"Bearer {SB_KEY}"
        }
    )
    try:
        with urllib.request.urlopen(req) as res:
            data = json.loads(res.read().decode('utf-8'))
            print("Database Records Sample:")
            pprint.pprint(data)
    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    main()
