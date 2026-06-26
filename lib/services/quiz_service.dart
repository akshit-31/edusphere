import 'api_service.dart';
import '../models/quiz_model.dart';

class QuizService {
  QuizService._privateConstructor();
  static final QuizService instance = QuizService._privateConstructor();

  // Fetch all quizzes (Student gets class filtered, Teacher gets all)
  Future<List<QuizModel>> fetchQuizzes() async {
    try {
      final res = await ApiService.instance.get('quizzes');
      if (res != null && res['success'] == true && res['data'] != null) {
        final list = res['data'] as List;
        return list.map((json) => QuizModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Create a new quiz (Teacher / Admin)
  Future<Map<String, dynamic>> createQuiz({
    required String title,
    required String subject,
    required int durationMinutes,
    String? targetClass,
    List<String>? targetSections,
    required List<QuizQuestionModel> questions,
  }) async {
    final res = await ApiService.instance.post('quizzes', body: {
      'title': title,
      'subject': subject,
      'durationMinutes': durationMinutes,
      'targetClass': targetClass,
      'targetSections': targetSections ?? [],
      'questions': questions.map((q) => q.toJson()).toList(),
    });
    return res as Map<String, dynamic>;
  }

  // Submit student's quiz answers
  Future<Map<String, dynamic>> submitQuizAttempt(String quizId, List<int> answers) async {
    final res = await ApiService.instance.post('quizzes/$quizId/submit', body: {
      'answers': answers,
    });
    return res as Map<String, dynamic>;
  }

  // Delete a quiz
  Future<bool> deleteQuiz(String quizId) async {
    try {
      final res = await ApiService.instance.delete('quizzes/$quizId');
      return res != null && res['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Fetch submissions for a quiz
  Future<List<Map<String, dynamic>>> fetchQuizSubmissions(String quizId) async {
    try {
      final res = await ApiService.instance.get('quizzes/$quizId/submissions');
      if (res != null && res['success'] == true && res['data'] != null) {
        return List<Map<String, dynamic>>.from(res['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
