import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final base = 'https://edusphere-erp.onrender.com/api/v1';
  try {
    print('Testing login for priya.joshi@edusphere.edu...');
    final response = await http.post(
      Uri.parse('$base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'priya.joshi@edusphere.edu',
        'password': 'edusphere',
      }),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
