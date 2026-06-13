import psycopg2
import sys

def main():
    password = "akshitsha84"
    project_ref = "bstevdkjqjzaglayicdg"
    username = f"postgres.{project_ref}"
    host = "aws-1-ap-south-1.pooler.supabase.com"
    db_uri = f"postgresql://{username}:{password}@{host}:6543/postgres"

    print("Connecting to database...")
    try:
        conn = psycopg2.connect(db_uri, connect_timeout=10)
        cursor = conn.cursor()
        print("Connected successfully!")

        table = 'Announcement'
        print(f"\n=== Schema of public.\"{table}\" ===")
        cursor.execute(f"""
            SELECT column_name, data_type, is_nullable 
            FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = '{table}';
        """)
        columns = cursor.fetchall()
        for col in columns:
            print(f"  {col[0]} ({col[1]}) - Nullable: {col[2]}")

        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
