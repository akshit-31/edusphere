import 'user_model.dart';

class StudentModel {
  final String id;
  final String userId;
  final String admissionNumber;
  final String? rollNumber;
  final String? currentClassId;
  final String? sectionId;
  final String? className;
  final String? sectionName;
  final String status;
  final UserModel? user;

  StudentModel({
    required this.id,
    required this.userId,
    required this.admissionNumber,
    this.rollNumber,
    this.currentClassId,
    this.sectionId,
    this.className,
    this.sectionName,
    required this.status,
    this.user,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    UserModel? userObj;
    if (json['user'] != null) {
      userObj = UserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map));
    }
    
    String? clsName;
    if (json['currentClass'] != null) {
      clsName = json['currentClass']['name'] as String?;
    } else {
      clsName = json['className'] as String?;
    }

    String? sectName;
    if (json['section'] != null) {
      sectName = json['section']['name'] as String?;
    } else {
      sectName = json['sectionName'] as String?;
    }

    return StudentModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      admissionNumber: json['admissionNumber'] as String? ?? '',
      rollNumber: json['rollNumber'] as String?,
      currentClassId: json['currentClassId'] as String?,
      sectionId: json['sectionId'] as String?,
      className: clsName,
      sectionName: sectName,
      status: json['status'] as String? ?? 'ACTIVE',
      user: userObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'admissionNumber': admissionNumber,
      'rollNumber': rollNumber,
      'currentClassId': currentClassId,
      'sectionId': sectionId,
      'className': className,
      'sectionName': sectionName,
      'status': status,
      'user': user?.toJson(),
    };
  }
}
