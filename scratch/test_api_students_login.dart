import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    print('1. Logging in to backend as testuser...');
    final loginUrl = Uri.parse('https://edusphere-erp-frontend.onrender.com/api/v1/auth/login');
    final loginRes = await http.post(
      loginUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': 'testuser@edusphere.edu',
        'password': 'testpassword123',
      }),
    );
    print('Login Status: ${loginRes.statusCode}');
    final loginData = jsonDecode(loginRes.body);
    String? token = loginData['token'];
    
    if (token == null || token.isEmpty) {
      print('Failed to get token');
      print('Response: ${loginRes.body}');
      return;
    }
    print('Token: ${token.substring(0, 10)}...');

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
    final students = studentsData['students'] ?? studentsData['data'] ?? [];
    print('Number of students: ${students.length}');
    if (students.isNotEmpty) {
      print('First Student keys: ${students[0].keys}');
      print('First Student:');
      print(JsonEncoder.withIndent('  ').convert(students[0]));
    }
  } catch (e) {
    print('Error: $e');
  }
}
