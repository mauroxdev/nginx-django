from django.http import HttpResponse

def health_check(request):
    # Here you can add more sophisticated checks, e.g., database connectivity
    try:
        from django.db import connection
        cursor = connection.cursor()
        cursor.execute("SELECT 1")
        row = cursor.fetchone()
        if row[0] != 1:
            return HttpResponse("Database check failed", status=500)
    except Exception as e:
        return HttpResponse(f"Database connection error: {e}", status=500)

    return HttpResponse("OK")
