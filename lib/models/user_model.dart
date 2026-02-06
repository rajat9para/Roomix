class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? token;
  final String? profilePicture;
  final Map<String, dynamic>? notificationSettings;
  final Map<String, dynamic>? privacySettings;
  final String? course;
  final String? year;
  final String? collegeName;
  final String? contactNumber;
  final double? campusLatitude;
  final double? campusLongitude;
  final String? campusAddress;
  final String? selectedUniversityId;
  final bool? isOnboardingComplete;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
    this.profilePicture,
    this.notificationSettings,
    this.privacySettings,
    this.course,
    this.year,
    this.collegeName,
    this.contactNumber,
    this.campusLatitude,
    this.campusLongitude,
    this.campusAddress,
    this.selectedUniversityId,
    this.isOnboardingComplete,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      token: json['token'],
      profilePicture: json['profilePicture'] ?? json['photoUrl'],
      notificationSettings: json['notificationSettings'] != null ? Map<String, dynamic>.from(json['notificationSettings']) : null,
      privacySettings: json['privacySettings'] != null ? Map<String, dynamic>.from(json['privacySettings']) : null,
      course: json['course'],
      year: json['year'],
      collegeName: json['collegeName'],
      contactNumber: json['contactNumber'],
      campusLatitude: json['campusLatitude'] != null ? (json['campusLatitude'] as num).toDouble() : null,
      campusLongitude: json['campusLongitude'] != null ? (json['campusLongitude'] as num).toDouble() : null,
      campusAddress: json['campusAddress'],
      selectedUniversityId: json['selectedUniversity']?['_id'] ?? json['selectedUniversity'],
      isOnboardingComplete: json['isOnboardingComplete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'token': token,
      'profilePicture': profilePicture,
      'notificationSettings': notificationSettings,
      'privacySettings': privacySettings,
      'course': course,
      'year': year,
      'collegeName': collegeName,
      'contactNumber': contactNumber,
      'campusLatitude': campusLatitude,
      'campusLongitude': campusLongitude,
      'campusAddress': campusAddress,
      'selectedUniversity': selectedUniversityId,
      'isOnboardingComplete': isOnboardingComplete,
    };
  }
}
