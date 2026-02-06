class RoommateProfile {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String bio;
  final List<String> interests;
  final RoommatePreferences preferences;
  final String gender;
  final String courseYear;
  final String college;
  final bool profileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? compatibility;

  RoommateProfile({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.bio,
    required this.interests,
    required this.preferences,
    required this.gender,
    required this.courseYear,
    required this.college,
    required this.profileComplete,
    required this.createdAt,
    required this.updatedAt,
    this.compatibility,
  });

  factory RoommateProfile.fromJson(Map<String, dynamic> json) {
    return RoommateProfile(
      id: json['_id'] ?? '',
      userId: json['user']?['_id'] ?? '',
      userName: json['user']?['name'] ?? 'Unknown',
      userEmail: json['user']?['email'] ?? '',
      bio: json['bio'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      preferences: RoommatePreferences.fromJson(json['preferences'] ?? {}),
      gender: json['gender'] ?? 'other',
      courseYear: json['courseYear'] ?? '',
      college: json['college'] ?? '',
      profileComplete: json['profileComplete'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      compatibility: json['compatibility'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'bio': bio,
      'interests': interests,
      'preferences': preferences.toJson(),
      'gender': gender,
      'courseYear': courseYear,
      'college': college,
      'profileComplete': profileComplete,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'compatibility': compatibility,
    };
  }
}

class RoommatePreferences {
  final BudgetRange budget;
  final List<String> location;
  final List<String> lifestyle;

  RoommatePreferences({
    required this.budget,
    required this.location,
    required this.lifestyle,
  });

  factory RoommatePreferences.fromJson(Map<String, dynamic> json) {
    return RoommatePreferences(
      budget: BudgetRange.fromJson(json['budget'] ?? {}),
      location: List<String>.from(json['location'] ?? []),
      lifestyle: List<String>.from(json['lifestyle'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'budget': budget.toJson(),
      'location': location,
      'lifestyle': lifestyle,
    };
  }
}

class BudgetRange {
  final double min;
  final double max;

  BudgetRange({
    required this.min,
    required this.max,
  });

  factory BudgetRange.fromJson(Map<String, dynamic> json) {
    return BudgetRange(
      min: (json['min'] ?? 5000).toDouble(),
      max: (json['max'] ?? 50000).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }
}
