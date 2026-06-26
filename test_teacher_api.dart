import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://edusphere-erp-latest-xffb.onrender.com/api/v1';
  
  // 1. Login
  print('Logging in as teacher teacher1@edusphere.com...');
  final loginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'email': 'teacher1@edusphere.com',
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

  // 2. Query academic/classes
  print('Querying academic/classes...');
  final classesRes = await http.get(
    Uri.parse('$baseUrl/academic/classes'),
    headers: headers,
  );
  print('Classes Status: ${classesRes.statusCode}');
  print('Classes Body: ${classesRes.body}');

  // 3. Query academic/sections
  print('Querying academic/sections...');
  final sectionsRes = await http.get(
    Uri.parse('$baseUrl/academic/sections'),
    headers: headers,
  );
  print('Sections Status: ${sectionsRes.statusCode}');
  print('Sections Body: ${sectionsRes.body}');
}
