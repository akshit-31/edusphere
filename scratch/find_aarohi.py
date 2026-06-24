import psycopg2

def main():
    try:
        conn = psycopg2.connect(
            host="aws-1-ap-south-1.pooler.supabase.com",
            port=5432,
            dbname="postgres",
            user="postgres.uodmjwjnhinbbvexbyvd",
            password="akshitsha84",
            sslmode="require"
        )
        cur = conn.cursor()
        cur.execute("""
            SELECT s.id, s."admissionNumber", u.id, u.email, u."firstName", u."lastName"
            FROM public."Student" s
            JOIN public."User" u ON s."userId" = u.id
            WHERE u."firstName" ILIKE '%Aarohi%' OR u."lastName" ILIKE '%Mishra%' OR u."firstName" ILIKE '%Mishra%' OR u."lastName" ILIKE '%Aarohi%';
        """)
        rows = cur.fetchall()
        print(f"Found {len(rows)} matching students:")
        for r in rows:
            print(f"Student ID: {r[0]} | AdmNo: {r[1]} | UserID: {r[2]} | Email: {r[3]} | Name: {r[4]} {r[5]}")
            
        cur.execute("""
            SELECT id, email, "firstName", "lastName", role
            FROM public."User"
            WHERE "firstName" ILIKE '%Aarohi%' OR "lastName" ILIKE '%Mishra%' OR "firstName" ILIKE '%Mishra%' OR "lastName" ILIKE '%Aarohi%';
        """)
        user_rows = cur.fetchall()
        print(f"\nFound {len(user_rows)} matching users:")
        for ur in user_rows:
            print(f"UserID: {ur[0]} | Email: {ur[1]} | Name: {ur[2]} {ur[3]} | Role: {ur[4]}")
            
        conn.close()
    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    main()
