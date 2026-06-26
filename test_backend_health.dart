import 'package:http/http.dart' as http;

void main() async {
  try {
    print('Testing edusphere-backend...');
    final res = await http.get(Uri.parse('https://edusphere-backend.onrender.com/api/v1/health')).timeout(Duration(seconds: 15));
    print('Backend Status: ${res.statusCode}');
    print('Backend Body: ${res.body}');
  } catch (e) {
    print('Backend Error: $e');
  }

  try {
    print('Testing edusphere-erp-frontend...');
    final res = await http.get(Uri.parse('https://edusphere-erp-frontend.onrender.com/api/v1/health')).timeout(Duration(seconds: 15));
    print('Frontend Status: ${res.statusCode}');
    print('Frontend Body: ${res.body}');
  } catch (e) {
    print('Frontend Error: $e');
  }
}
