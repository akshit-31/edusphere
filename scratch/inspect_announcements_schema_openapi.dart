import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE';
  final baseUrl = 'https://bstevdkjqjzaglayicdg.supabase.co/rest/v1';

  final headers = {
    'apikey': anonKey,
    'Authorization': 'Bearer $anonKey',
  };

  try {
    final res = await http.get(
      Uri.parse('$baseUrl/'),
      headers: headers,
    );
    print('Status: ${res.statusCode}');
    if (res.statusCode == 200) {
      final Map schema = jsonDecode(res.body);
      final definitions = schema['definitions'] as Map?;
      if (definitions != null && definitions.containsKey('Announcement')) {
        final annDef = definitions['Announcement'] as Map?;
        final properties = annDef?['properties'] as Map?;
        print('Announcement properties:');
        properties?.forEach((key, val) {
          print('  $key: $val');
        });
      } else {
        print('Announcement definition not found in OpenAPI schema.');
      }
    } else {
      print('Error: ${res.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
