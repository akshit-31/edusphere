import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://edusphere-erp-latest-xffb.onrender.com/api/v1';
  
  // 1. Login
  print('Logging in as student student1@edusphere.com on the real backend...');
  final loginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'email': 'student1@edusphere.com',
      'password': 'Password@123',
    }),
  );

  print('Login Status: ${loginRes.statusCode}');
  if (loginRes.statusCode != 200) {
    print('Login failed: ${loginRes.body}');
    return;
  }

  final loginData = jsonDecode(loginRes.body);
  final token = loginData['token'] as String?;
  final user = loginData['user'] as Map?;
  
  print('User from login: $user');

  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // 2. Query students/me to find student profile ID
  print('Querying students/me...');
  final meRes = await http.get(
    Uri.parse('$baseUrl/students/me'),
    headers: headers,
  );
  print('Me Status: ${meRes.statusCode}');
  print('Me Body: ${meRes.body}');

  if (meRes.statusCode != 200) {
    print('Failed to query students/me');
    return;
  }

  final meData = jsonDecode(meRes.body);
  final student = meData['student'] as Map?;
  final studentId = student?['id'] as String?;
  print('Resolved Student ID: $studentId');

  if (studentId == null) {
    print('Failed to resolve student ID from /students/me');
    return;
  }

  // 3. Query endpoint A: students/:studentId/attendance
  print('Querying students/:studentId/attendance...');
  final resA = await http.get(
    Uri.parse('$baseUrl/students/$studentId/attendance'),
    headers: headers,
  );
  print('Res A Status: ${resA.statusCode}');
  print('Res A Body: ${resA.body}');

  // 4. Query endpoint B: attendance/student/:studentId
  print('Querying attendance/student/:studentId...');
  final resB = await http.get(
    Uri.parse('$baseUrl/attendance/student/$studentId'),
    headers: headers,
  );
  print('Res B Status: ${resB.statusCode}');
  print('Res B Body: ${resB.body}');
}
