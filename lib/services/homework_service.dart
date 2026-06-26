import 'api_service.dart';
import '../models/homework_model.dart';

class HomeworkService {
  HomeworkService._privateConstructor();
  static final HomeworkService instance = HomeworkService._privateConstructor();

  // Get active assignments for a student
  Future<List<HomeworkModel>> getStudentHomework() async {
    try {
      final res = await ApiService.instance.get('assignments/student');
      if (res != null && res['assignments'] != null) {
        final list = res['assignments'] as List;
        return list.map((json) => HomeworkModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get assignments created by a teacher
  Future<List<HomeworkModel>> getTeacherHomework() async {
    try {
      final res = await ApiService.instance.get('assignments/teacher');
      if (res != null && res['assignments'] != null) {
        final list = res['assignments'] as List;
        return list.map((json) => HomeworkModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Create a new homework assignment
  Future<Map<String, dynamic>> createHomework({
    required String title,
    required String description,
    required String dueDate,
    required String subjectId,
    required String classId,
    String? sectionId,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    if (fileBytes != null && fileName != null) {
      final res = await ApiService.instance.multipartRequest(
        'POST',
        'assignments',
        fileKey: 'file',
        fileBytes: fileBytes,
        fileName: fileName,
        fields: {
          'title': title,
          'description': description,
          'dueDate': dueDate,
          'subjectId': subjectId,
          'classId': classId,
          if (sectionId != null) 'sectionId': sectionId,
        },
      );
      return res as Map<String, dynamic>;
    } else {
      final res = await ApiService.instance.post('assignments', body: {
        'title': title,
        'description': description,
        'dueDate': dueDate,
        'subjectId': subjectId,
        'classId': classId,
        if (sectionId != null) 'sectionId': sectionId,
      });
      return res as Map<String, dynamic>;
    }
  }

  // Submit student's homework
  Future<Map<String, dynamic>> submitHomework({
    required String assignmentId,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    if (fileBytes != null && fileName != null) {
      final res = await ApiService.instance.multipartRequest(
        'POST',
        'assignments/submit',
        fileKey: 'file',
        fileBytes: fileBytes,
        fileName: fileName,
        fields: {
          'assignmentId': assignmentId,
        },
      );
      return res as Map<String, dynamic>;
    } else {
      final res = await ApiService.instance.post('assignments/submit', body: {
        'assignmentId': assignmentId,
      });
      return res as Map<String, dynamic>;
    }
  }
}
