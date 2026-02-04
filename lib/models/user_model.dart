class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? token;
  final String? profilePicture;
  final Map<String, dynamic>? notificationSettings;
  final Map<String, dynamic>? privacySettings;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
    this.profilePicture,
    this.notificationSettings,
    this.privacySettings,
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
    };
  }
}
