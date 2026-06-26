class HomeworkModel {
  final String id;
  final String title;
  final String? description;
  final String? filePath;
  final DateTime dueDate;
  final String subjectId;
  final String classId;
  final String? sectionId;
  final String teacherId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Enriched fields from relations
  final String? subjectName;
  final String? teacherName;
  final String? submissionStatus;
  final String? submissionGrade;
  final DateTime? submittedAt;

  HomeworkModel({
    required this.id,
    required this.title,
    this.description,
    this.filePath,
    required this.dueDate,
    required this.subjectId,
    required this.classId,
    this.sectionId,
    required this.teacherId,
    required this.createdAt,
    required this.updatedAt,
    this.subjectName,
    this.teacherName,
    this.submissionStatus,
    this.submissionGrade,
    this.submittedAt,
  });

  factory HomeworkModel.fromJson(Map<String, dynamic> json) {
    // Parse subject relation
    final subjectData = json['subject'] as Map<String, dynamic>?;
    final subjectName = subjectData?['name'] as String?;

    // Parse teacher relation
    final teacherData = json['teacher'] as Map<String, dynamic>?;
    final userData = teacherData?['user'] as Map<String, dynamic>?;
    String? teacherName;
    if (userData != null) {
      final first = userData['firstName'] as String? ?? '';
      final last = userData['lastName'] as String? ?? '';
      teacherName = '$first $last'.trim();
    }

    // Parse student's own submission data if present
    final submissionsList = json['submissions'] as List?;
    String? submissionStatus;
    String? submissionGrade;
    DateTime? submittedAt;
    if (submissionsList != null && submissionsList.isNotEmpty) {
      final sub = submissionsList[0] as Map<String, dynamic>;
      submissionStatus = sub['status'] as String?;
      submissionGrade = sub['grade'] as String?;
      final subAtStr = sub['submittedAt'] as String?;
      if (subAtStr != null) {
        submittedAt = DateTime.tryParse(subAtStr);
      }
    }

    return HomeworkModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      filePath: json['filePath'] as String?,
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
      subjectId: json['subjectId'] as String? ?? '',
      classId: json['classId'] as String? ?? '',
      sectionId: json['sectionId'] as String?,
      teacherId: json['teacherId'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      subjectName: subjectName,
      teacherName: teacherName,
      submissionStatus: submissionStatus,
      submissionGrade: submissionGrade,
      submittedAt: submittedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'filePath': filePath,
      'dueDate': dueDate.toIso8601String(),
      'subjectId': subjectId,
      'classId': classId,
      'sectionId': sectionId,
      'teacherId': teacherId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
