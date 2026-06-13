import 'dart:convert';
import 'dart:io';

void main() async {
  final url = 'https://bstevdkjqjzaglayicdg.supabase.co/rest/v1';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE';

  final client = HttpClient();
  
  Future<dynamic> getTable(String table, [String query = '']) async {
    final uri = Uri.parse('$url/$table?$query');
    final request = await client.getUrl(uri);
    request.headers.add('apikey', anonKey);
    request.headers.add('Authorization', 'Bearer $anonKey');
    
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (body.isEmpty) return null;
    return jsonDecode(body);
  }

  try {
    print('Fetching users with role TEACHER...');
    final users = await getTable('User', 'role=eq.TEACHER');
    if (users is List) {
      for (var u in users) {
        print('User: email=${u['email']}, role=${u['role']}, name=${u['firstName']} ${u['lastName']}');
      }
    } else {
      print('Response: $users');
    }
  } catch (e, stack) {
    print('Error: $e\n$stack');
  } finally {
    client.close();
  }
}
