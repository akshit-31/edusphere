import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final base = 'https://edusphere-erp.onrender.com/api/v1';
  try {
    print('Testing login for teacher1@edusphere.com...');
    final response = await http.post(
      Uri.parse('$base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'teacher1@edusphere.com',
        'password': 'edusphere',
      }),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
