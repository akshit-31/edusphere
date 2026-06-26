import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://edusphere-erp-frontend.onrender.com/api/v1';
  final loginUrl = Uri.parse('$baseUrl/auth/login');
  try {
    print('1. Logging in student2@edusphere.com...');
    final loginRes = await http.post(
      loginUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': 'student2@edusphere.com',
        'password': 'Password@123',
      }),
    );

    if (loginRes.statusCode != 200) {
      print('Login failed: ${loginRes.body}');
      return;
    }

    final data = jsonDecode(loginRes.body);
    final token = data['token'];
    final studentId = '94c47b6c-3518-44d4-84f3-785dde9d9930'; // Resolved earlier
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final endpoints = [
      'students/me',
      'assignments/student',
      'fees/students/me/status',
      'library/issues?studentId=$studentId&status=ISSUED',
      'calendar?startDate=2026-01-01&endDate=2026-12-31',
      'calendar/upcoming?limit=10',
    ];

    for (var ep in endpoints) {
      print('\nTesting GET endpoint: /$ep...');
      final uri = Uri.parse('$baseUrl/$ep');
      final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      print('Status: ${res.statusCode}');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        print('Response keys: ${body.keys.toList()}');
      } else {
        print('Response: ${res.body}');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
