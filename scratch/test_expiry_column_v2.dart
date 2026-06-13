import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE';
  final baseUrl = 'https://bstevdkjqjzaglayicdg.supabase.co/rest/v1';

  final headers = {
    'apikey': anonKey,
    'Authorization': 'Bearer $anonKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=minimal',
  };

  // 1. Try with expiresAt
  try {
    final res = await http.post(
      Uri.parse('$baseUrl/Announcement'),
      headers: headers,
      body: jsonEncode({
        'id': 'test_expiresAt_col',
        'title': 'Test Title',
        'content': 'Test Content',
        'priority': 'NORMAL',
        'targetAudience': ['ALL'],
        'expiresAt': DateTime.now().toIso8601String(),
      }),
    );
    print('expiresAt Insert Status: ${res.statusCode}');
    print('expiresAt Insert Response: ${res.body}');
  } catch (e) {
    print('expiresAt Exception: $e');
  }

  // 2. Try with expires_at
  try {
    final res = await http.post(
      Uri.parse('$baseUrl/Announcement'),
      headers: headers,
      body: jsonEncode({
        'id': 'test_expires_at_col',
        'title': 'Test Title',
        'content': 'Test Content',
        'priority': 'NORMAL',
        'targetAudience': ['ALL'],
        'expires_at': DateTime.now().toIso8601String(),
      }),
    );
    print('expires_at Insert Status: ${res.statusCode}');
    print('expires_at Insert Response: ${res.body}');
  } catch (e) {
    print('expires_at Exception: $e');
  }
}
