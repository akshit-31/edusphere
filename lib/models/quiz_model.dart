class QuizQuestionModel {
  final String question;
  final List<String> options;
  final int ans; // 0-based index of correct option

  QuizQuestionModel({
    required this.question,
    required this.options,
    required this.ans,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List? ?? [];
    return QuizQuestionModel(
      question: json['question'] as String? ?? json['q'] as String? ?? '',
      options: rawOptions.map((e) => e.toString()).toList(),
      ans: json['ans'] as int? ?? json['answerIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'ans': ans,
    };
  }
}

class QuizModel {
  final String id;
  final String title;
  final String subject;
  final int durationMinutes;
  final String? targetClass;
  final List<String> targetSections;
  final List<QuizQuestionModel> questions;
  final bool isPublished;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Custom helper fields for student attempts
  final bool isAttempted;
  final int? score;
  final int? totalQuestions;
  final List<int>? studentAnswers;

  QuizModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.durationMinutes,
    this.targetClass,
    required this.targetSections,
    required this.questions,
    required this.isPublished,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isAttempted = false,
    this.score,
    this.totalQuestions,
    this.studentAnswers,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final rawSections = json['targetSections'] as List? ?? [];
    final rawQuestions = json['questions'] as List? ?? [];
    
    return QuizModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? 'General',
      durationMinutes: json['durationMinutes'] as int? ?? 20,
      targetClass: json['targetClass'] as String?,
      targetSections: rawSections.map((e) => e.toString()).toList(),
      questions: rawQuestions.map((q) => QuizQuestionModel.fromJson(q as Map<String, dynamic>)).toList(),
      isPublished: json['isPublished'] as bool? ?? true,
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      isAttempted: json['isAttempted'] as bool? ?? false,
      score: json['score'] as int?,
      totalQuestions: json['totalQuestions'] as int?,
      studentAnswers: (json['answers'] as List?)?.map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'durationMinutes': durationMinutes,
      'targetClass': targetClass,
      'targetSections': targetSections,
      'questions': questions.map((q) => q.toJson()).toList(),
      'isPublished': isPublished,
      'createdBy': createdBy,
    };
  }
}
