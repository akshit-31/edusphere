import 'dart:convert';
import 'package:http/http.dart' as http;
void main() async {
  // Let's try to fetch from the API without a token
  final res = await http.get(Uri.parse('https://edusphere-erp-frontend.onrender.com/api/v1/students?limit=500'));
  print('Status: ${res.statusCode}');
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    final students = data['students'] ?? data['data'] ?? [];
    print('Total students: ${students.length}');
  } else {
    print('Body: ${res.body}');
  }
}
