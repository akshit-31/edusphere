class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final List<String> roles;
  final String? phone;
  final String? avatar;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.roles,
    this.phone,
    this.avatar,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      roles: (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? [json['role'] as String? ?? ''],
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      address: json['address'] as String?,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.tryParse(json['dateOfBirth'].toString()) : null,
      gender: json['gender'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'roles': roles,
      'phone': phone,
      'avatar': avatar,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup,
    };
  }
}

// Legacy AppUser class for backward compatibility
class AppUser {
  final String name;
  final String email;
  final String role;
  final String subtitle;
  final String avatarSeed;

  const AppUser({
    required this.name,
    required this.email,
    required this.role,
    required this.subtitle,
    required this.avatarSeed,
  });
}
