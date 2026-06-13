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

  // 1. Try with expiryDate
  try {
    final res = await http.post(
      Uri.parse('$baseUrl/Announcement'),
      headers: headers,
      body: jsonEncode({
        'id': 'test_expiryDate_col',
        'title': 'Test Title',
        'content': 'Test Content',
        'priority': 'NORMAL',
        'targetAudience': ['ALL'],
        'expiryDate': DateTime.now().toIso8601String(),
      }),
    );
    print('expiryDate Insert Status: ${res.statusCode}');
    print('expiryDate Insert Response: ${res.body}');
  } catch (e) {
    print('expiryDate Exception: $e');
  }

  // 2. Try with expiry_date
  try {
    final res = await http.post(
      Uri.parse('$baseUrl/Announcement'),
      headers: headers,
      body: jsonEncode({
        'id': 'test_expiry_date_col',
        'title': 'Test Title',
        'content': 'Test Content',
        'priority': 'NORMAL',
        'targetAudience': ['ALL'],
        'expiry_date': DateTime.now().toIso8601String(),
      }),
    );
    print('expiry_date Insert Status: ${res.statusCode}');
    print('expiry_date Insert Response: ${res.body}');
  } catch (e) {
    print('expiry_date Exception: $e');
  }
}
