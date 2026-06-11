import psycopg2

conn = psycopg2.connect(
    host="aws-0-ap-south-1.pooler.supabase.com",
    port=5432,
    dbname="postgres",
    user="postgres.uodmjwjnhinbbvexbyvd",
    password="akshitsha84",
    sslmode="require"
)
cur = conn.cursor()

# Query transport allocation for student Kavita Das
cur.execute('SELECT * FROM public."TransportAllocation" WHERE "studentId"=\'2171b290-bccc-4a81-95eb-b857cf81f3ed\'')
print("Allocations:", cur.fetchall())

# Query stops
cur.execute('SELECT id, name, "routeId", "arrivalTime" FROM public."RouteStop"')
print("Stops:", cur.fetchall())

# Query routes
cur.execute('SELECT id, name, "startLocation", "endLocation" FROM public."TransportRoute"')
print("Routes:", cur.fetchall())

conn.close()
