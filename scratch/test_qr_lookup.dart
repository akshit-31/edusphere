import 'dart:convert';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://bstevdkjqjzaglayicdg.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE'
  );

  // The QR code data containing the JSON string
  const rawQrCode = '{"uid":"3f7b0a51-6d42-44e3-af7d-f528874236d3","v":1}';
  print('Raw QR Payload: $rawQrCode');

  try {
    final codeTrimmed = rawQrCode.trim();
    String resolvedIdentifier = codeTrimmed;

    if (codeTrimmed.startsWith('{') && codeTrimmed.endsWith('}')) {
      final Map<String, dynamic> jsonMap = jsonDecode(codeTrimmed);
      if (jsonMap.containsKey('uid')) {
        resolvedIdentifier = jsonMap['uid'].toString().trim();
        print('Extracted UID: $resolvedIdentifier');
      }
    }

    print('Querying database with identifier: $resolvedIdentifier...');
    
    // Querying Student by admissionNumber, userId, or id
    final studentRes = await supabase
        .from('Student')
        .select('id, user:User(firstName, lastName)')
        .or('admissionNumber.eq.$resolvedIdentifier,userId.eq.$resolvedIdentifier,id.eq.$resolvedIdentifier')
        .maybeSingle();

    if (studentRes != null) {
      final studentId = studentRes['id'].toString();
      final user = studentRes['user'] as Map<String, dynamic>? ?? {};
      final studentName = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
      print('✅ SUCCESS! Student Found:');
      print('  Name: $studentName');
      print('  Student ID: $studentId');
    } else {
      print('❌ FAILED: Student not found for identifier.');
    }

  } catch (e) {
    print('❌ ERROR: $e');
  } finally {
    supabase.dispose();
  }
}
