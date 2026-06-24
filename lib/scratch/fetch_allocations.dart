import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> dumpTransportAllocations() async {
  try {
    final client = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('student_id');
    final userId = client.auth.currentUser?.id;
    
    debugPrint('--- TRANSPORT ALLOC DUMP ---');
    debugPrint('Current student_id in prefs: $studentId');
    debugPrint('Current user_id: $userId');

    final response = await client.from('TransportAllocation').select('*');
    debugPrint('TransportAllocations in DB: $response');
  } catch (e) {
    debugPrint('Error dumping: $e');
  }
}
