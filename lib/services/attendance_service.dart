import 'api_service.dart';

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
}
