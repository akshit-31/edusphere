import 'dart:convert';
import 'dart:io';

void main() async {
  final url = 'https://bstevdkjqjzaglayicdg.supabase.co/rest/v1';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE';

  final client = HttpClient();
  
  try {
    final uri = Uri.parse('$url/User?select=email,role,password&limit=100');
    final request = await client.getUrl(uri);
    request.headers.add('apikey', anonKey);
    request.headers.add('Authorization', 'Bearer $anonKey');
    
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (body.isEmpty) {
      print('Body is empty');
      return;
    }
    final List data = jsonDecode(body);
    final hashes = <String, List<String>>{};
    for (var u in data) {
      final email = u['email'] as String;
      final role = u['role'] as String;
      final hash = u['password'] as String? ?? 'NULL';
      hashes.putIfAbsent(hash, () => []).add('$email ($role)');
    }
    
    print('--- Unique Password Hashes ---');
    hashes.forEach((hash, emails) {
      print('Hash: $hash');
      print('Emails (${emails.length}): ${emails.take(5).join(', ')}${emails.length > 5 ? "..." : ""}');
      print('');
    });
  } catch (e, stack) {
    print('Error: $e\n$stack');
  } finally {
    client.close();
  }
}
