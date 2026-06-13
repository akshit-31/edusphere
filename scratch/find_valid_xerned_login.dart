import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final base = 'https://edusphere-erp.onrender.com/api/v1';
  final emails = [
    "admin@demoschool.com",
    "principal@demoschool.com",
    "hr@demoschool.com",
    "accountant@demoschool.com",
    "teacher2@demoschool.com",
    "teacher3@demoschool.com",
    "teacher1@demoschool.com"
  ];

  final passwords = [
    "edusphere",
    "Teacher@123",
    "Teacher@2024",
    "Admin@2024",
    "password"
  ];

  for (var email in emails) {
    for (var pass in passwords) {
      try {
        final response = await http.post(
          Uri.parse('$base/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': pass,
          }),
        );
        if (response.statusCode == 200) {
          print('🎉 SUCCESS: $email / $pass');
          print('Body: ${response.body}');
          return;
        }
      } catch (e) {
        // ignore
      }
    }
  }
  print('All combinations failed.');
}
