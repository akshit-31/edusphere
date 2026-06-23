import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    print('1. Logging in to backend...');
    final loginUrl = Uri.parse('https://edusphere-erp-frontend.onrender.com/api/v1/auth/login');
    final loginRes = await http.post(
      loginUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': 'priya.joshi@edusphere.edu',
        'password': 'edusphere',
      }),
    );
    print('Login Status: ${loginRes.statusCode}');
    final loginData = jsonDecode(loginRes.body);
    String? token = loginData['token'];
    if (token == null || token.isEmpty) {
      final setCookie = loginRes.headers['set-cookie'];
      if (setCookie != null) {
        final match = RegExp(r'auth_token=([^;]+)').firstMatch(setCookie);
        if (match != null) {
          token = match.group(1);
        }
      }
    }
    
    if (token == null || token.isEmpty) {
      print('Failed to get token');
      return;
    }
    print('Token obtained successfully: ${token.substring(0, 10)}...');

    print('\n2. Fetching students from API with token...');
    final studentsUrl = Uri.parse('https://edusphere-erp-frontend.onrender.com/api/v1/students?limit=5');
    final studentsRes = await http.get(
      studentsUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('Students Fetch Status: ${studentsRes.statusCode}');
    final studentsData = jsonDecode(studentsRes.body);
    print('Data keys: ${studentsData.keys}');
    final students = studentsData['students'] ?? studentsData['data'] ?? [];
    print('Number of students: ${students.length}');
    if (students.isNotEmpty) {
      print('First Student details:');
      print(JsonEncoder.withIndent('  ').convert(students[0]));
    }
  } catch (e) {
    print('Error: $e');
  }
}
