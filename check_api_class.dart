import 'dart:convert';
import 'package:http/http.dart' as http;
void main() async {
  final res = await http.get(Uri.parse('https://edusphere-erp-frontend.onrender.com/api/v1/classes?limit=50'));
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    final classes = data['classes'] ?? data['data'] ?? [];
    for (var c in classes) {
      if (c['name'] == 'Class 8') {
        print('API Class 8 ID: ${c['id']}');
      }
    }
  } else {
    print(res.body);
  }
}
