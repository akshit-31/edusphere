import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'package:dio/dio.dart';

class AttendanceService {
  AttendanceService._privateConstructor();
  static final AttendanceService instance = AttendanceService._privateConstructor();

  Future<Map<String, dynamic>> markAttendance({
    required String studentId,
    required String date,
    required String status,
    String? remarks,
  }) async {
    final response = await ApiService.instance.post('attendance/mark', body: {
      'studentId': studentId,
      'date': date,
      'status': status,
      if (remarks != null) 'remarks': remarks,
    });
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> bulkMarkAttendance({
    required String classId,
    required String sectionId,
    required String date,
    required List<Map<String, String>> students,
  }) async {
    final response = await ApiService.instance.post('attendance/bulk', body: {
      'classId': classId,
      'sectionId': sectionId,
      'date': date,
      'students': students,
    });
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudentAttendance(String studentId, {String? startDate, String? endDate}) async {
    final queryParams = {
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };
    final response = await ApiService.instance.get('students/$studentId/attendance', queryParams: queryParams);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAttendanceByDate(String date) async {
    final response = await ApiService.instance.get('attendance/date', queryParams: {'date': date});
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAttendanceAnalytics({
    String? classId,
    String? sectionId,
    required String startDate,
    required String endDate,
  }) async {
    final queryParams = {
      if (classId != null) 'classId': classId,
      if (sectionId != null) 'sectionId': sectionId,
      'startDate': startDate,
      'endDate': endDate,
      'attendeeType': 'STUDENT',
    };
    final response = await ApiService.instance.get('attendance/analytics', queryParams: queryParams);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMyAttendance() async {
    final response = await ApiService.instance.get('attendance/my');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createSlot({
    required String date,
    required String classId,
    String? sectionId,
  }) async {
    final response = await ApiService.instance.post('attendance/slots', body: {
      'date': date,
      'classId': classId,
      if (sectionId != null) 'sectionId': sectionId,
      'attendeeType': 'STUDENT',
    });
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSlots({
    required String date,
    String? classId,
  }) async {
    final queryParams = {
      'date': date,
      if (classId != null) 'classId': classId,
      'attendeeType': 'STUDENT',
    };
    final response = await ApiService.instance.get('attendance/slots', queryParams: queryParams);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSlotWithStudents(String slotId) async {
    final response = await ApiService.instance.get('attendance/slots/$slotId');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> submitSlotAttendance(
    String slotId,
    List<Map<String, dynamic>> attendanceData,
  ) async {
    if (kDebugMode) {
      print('--- ATTENDANCE SUBMISSION REQUEST ---');
      print('HTTP Method: POST');
      print('URL: ${ApiService.instance.dio.options.baseUrl}attendance/slots/$slotId/submit');
      print('Headers: {');
      print('  Accept: application/json,');
      print('  Content-Type: application/json,');
      print('  Authorization: Bearer ${ApiService.instance.token ?? ""}');
      print('}');
      print('Request Body JSON: ${jsonEncode({"attendanceData": attendanceData})}');
      print('-------------------------------------');
    }

    try {
      final response = await ApiService.instance.post('attendance/slots/$slotId/submit', body: {
        'attendanceData': attendanceData,
      });

      if (kDebugMode) {
        print('--- ATTENDANCE SUBMISSION RESPONSE ---');
        print('Status Code: 200/201');
        print('Response Body: ${jsonEncode(response)}');
        print('--------------------------------------');
      }

      return response as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('--- ATTENDANCE SUBMISSION ERROR ---');
        print('Error message: $e');
        if (e is DioException) {
          print('Status Code: ${e.response?.statusCode}');
          print('Response Headers: ${e.response?.headers}');
          print('Response Body: ${e.response?.data}');
        }
        print('-----------------------------------');
      }

      bool isUniqueConstraintError = e.toString().toLowerCase().contains('unique constraint') ||
          e.toString().toLowerCase().contains('studentid,date');
      
      if (e is DioException) {
        final res = e.response;
        if (res != null) {
          if (res.statusCode == 409 || res.statusCode == 400) {
            isUniqueConstraintError = true;
          }
          if (res.data != null) {
            final dataStr = res.data.toString().toLowerCase();
            if (dataStr.contains('unique constraint') || dataStr.contains('studentid,date')) {
              isUniqueConstraintError = true;
            }
          }
        }
      }
      
      if (isUniqueConstraintError) {
        try {
          if (kDebugMode) {
            print('⚠️ Unique constraint/409/400 conflict detected. Initializing self-healing fallback via bulkMarkAttendance...');
          }
          final slotData = await getSlotWithStudents(slotId);
          
          final slot = (slotData['slot'] ?? slotData['data']) as Map<String, dynamic>?;
          if (slot != null) {
            final String? classId = slot['classId']?.toString();
            final String? sectionId = slot['sectionId']?.toString();
            final String? date = slot['date']?.toString();
            
            if (classId != null && date != null) {
              String formattedDate = date;
              try {
                final parsedDate = DateTime.parse(date);
                formattedDate = "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
              } catch (_) {}

              final bulkPayload = {
                'date': formattedDate,
                if (classId != null) 'classId': classId,
                if (sectionId != null) 'sectionId': sectionId,
                'attendanceData': attendanceData.map((item) => {
                  'studentId': item['entityId'],
                  'status': item['status'],
                }).toList(),
                'students': attendanceData.map((item) => {
                  'studentId': item['entityId'],
                  'status': item['status'],
                }).toList(),
              };

              if (kDebugMode) {
                print('--- ATTENDANCE BULK SUBMISSION REQUEST (FALLBACK) ---');
                print('HTTP Method: POST');
                print('URL: ${ApiService.instance.dio.options.baseUrl}attendance/bulk');
                print('Headers: {');
                print('  Accept: application/json,');
                print('  Content-Type: application/json,');
                print('  Authorization: Bearer ${ApiService.instance.token ?? ""}');
                print('}');
                print('Request Body JSON: ${jsonEncode(bulkPayload)}');
                print('----------------------------------------------------');
              }

              final response = await ApiService.instance.post('attendance/bulk', body: bulkPayload);

              if (kDebugMode) {
                print('--- ATTENDANCE BULK SUBMISSION RESPONSE (FALLBACK) ---');
                print('Status Code: 200/201');
                print('Response Body: ${jsonEncode(response)}');
                print('-----------------------------------------------------');
              }

              return response as Map<String, dynamic>;
            }
          }
        } catch (fallbackErr) {
          if (kDebugMode) {
            print('❌ Fallback execution failed: $fallbackErr');
            if (fallbackErr is DioException) {
              print('Fallback Response Status: ${fallbackErr.response?.statusCode}');
              print('Fallback Response Body: ${fallbackErr.response?.data}');
            }
          }
          rethrow;
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteSlot(String slotId) async {
    final response = await ApiService.instance.delete('attendance/slots/$slotId');
    return response as Map<String, dynamic>;
  }
}
