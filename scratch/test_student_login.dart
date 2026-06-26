import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://edusphere-erp-frontend.onrender.com/api/v1';
  final loginUrl = Uri.parse('$baseUrl/auth/login');
  try {
    print('Sending login request to: $loginUrl');
    final res = await http.post(
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

    print('Response status: ${res.statusCode}');
    final data = jsonDecode(res.body);
    if (data['success'] != true) {
      print('Login failed: $data');
      return;
    }

    final token = data['token'];
    print('Login successful. Token: $token');

    final profileUrl = Uri.parse('$baseUrl/students/me');
    print('Fetching student profile from: $profileUrl');
    final profileRes = await http.get(
      profileUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Profile response status: ${profileRes.statusCode}');
    print('Profile response body: ${profileRes.body}');
  } catch (e) {
    print('Error: $e');
  }
}
