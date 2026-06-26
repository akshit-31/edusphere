import 'user_model.dart';

class TeacherModel {
  final String id;
  final String userId;
  final String employeeId;
  final String qualification;
  final int? experience;
  final String? specialization;
  final String? assignedScannerId;
  final String status;
  final UserModel? user;

  TeacherModel({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.qualification,
    this.experience,
    this.specialization,
    this.assignedScannerId,
    required this.status,
    this.user,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    UserModel? userObj;
    if (json['user'] != null) {
      userObj = UserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map));
    }

    return TeacherModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      employeeId: json['employeeId'] as String? ?? '',
      qualification: json['qualification'] as String? ?? '',
      experience: json['experience'] as int?,
      specialization: json['specialization'] as String?,
      assignedScannerId: json['assignedScannerId'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      user: userObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'employeeId': employeeId,
      'qualification': qualification,
      'experience': experience,
      'specialization': specialization,
      'assignedScannerId': assignedScannerId,
      'status': status,
      'user': user?.toJson(),
    };
  }
}
