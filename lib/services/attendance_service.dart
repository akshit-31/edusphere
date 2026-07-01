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
    try {
      final response = await ApiService.instance.post('attendance/slots/$slotId/submit', body: {
        'attendanceData': attendanceData,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      bool isUniqueConstraintError = e.toString().toLowerCase().contains('unique constraint') ||
          e.toString().toLowerCase().contains('studentid,date');
      
      if (e is DioException) {
        final res = e.response;
        if (res != null) {
          if (res.statusCode == 409) {
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
          // Self-healing fallback: fetch slot info, filter out students with existing records not matching this slotId, and retry submit
          final slotData = await getSlotWithStudents(slotId);
          
          Map<String, dynamic> existing = {};
          final rawAttendance = slotData['attendance'] ?? slotData['attendanceMap'];
          if (rawAttendance is Map) {
            existing = Map<String, dynamic>.from(rawAttendance);
          } else {
            final data = slotData['data'];
            if (data is Map) {
              final nestedAttendance = data['attendance'] ?? data['attendanceMap'];
              if (nestedAttendance is Map) {
                existing = Map<String, dynamic>.from(nestedAttendance);
              }
            }
          }

          final filteredData = attendanceData.where((item) {
            final String? entityId = item['entityId']?.toString();
            if (entityId != null && existing.containsKey(entityId)) {
              final record = existing[entityId];
              if (record is Map) {
                final String? recordSlotId = record['slotId']?.toString();
                if (recordSlotId != slotId) {
                  return false; // Filter out to avoid unique constraint crash
                }
              }
            }
            return true;
          }).toList();

          if (filteredData.isNotEmpty) {
            final response = await ApiService.instance.post('attendance/slots/$slotId/submit', body: {
              'attendanceData': filteredData,
            });
            return response as Map<String, dynamic>;
          } else {
            return {
              'success': true,
              'message': 'All students already marked',
              'count': 0
            };
          }
        } catch (fallbackErr) {
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
