import psycopg2

def main():
    password = "akshitsha84"
    ref = "xernedkpgdrvjokokdoa"
    username = f"postgres.{ref}"
    host = "aws-1-ap-south-1.pooler.supabase.com"
    db_uri = f"postgresql://{username}:{password}@{host}:6543/postgres"
    
    print("Connecting to DB...")
    try:
        conn = psycopg2.connect(db_uri)
        cursor = conn.cursor()
        print("Connected!")
        
        print("\n--- Classes ---")
        cursor.execute("SELECT id, name, \"classTeacherId\" FROM public.\"Class\";")
        classes = cursor.fetchall()
        for c in classes:
            print(f"Class: ID={c[0]}, Name={c[1]}, TeacherID={c[2]}")
            
        print("\n--- Sections ---")
        cursor.execute("SELECT id, name, \"classId\" FROM public.\"Section\";")
        sections = cursor.fetchall()
        for s in sections:
            print(f"Section: ID={s[0]}, Name={s[1]}, ClassID={s[2]}")
            
        print("\n--- Teachers ---")
        cursor.execute("SELECT t.id, u.email, u.\"firstName\", u.\"lastName\" FROM public.\"Teacher\" t JOIN public.\"User\" u ON t.\"userId\" = u.id;")
        teachers = cursor.fetchall()
        for t in teachers:
            print(f"Teacher: ID={t[0]}, Email={t[1]}, Name={t[2]} {t[3]}")
            
        cursor.close()
        conn.close()
    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    main()
