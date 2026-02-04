class UtilityModel {
  final String id;
  final String name;
  final String category;
  final double latitude;
  final double longitude;
  final String? address;
  final Map<String, dynamic>? contact;
  final String? description;
  final String? image;
  final bool verified;
  final String addedBy;
  final double rating;
  final List<Review> reviews;
  final Map<String, dynamic>? operatingHours;
  final List<String>? tags;
  final bool isActive;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  UtilityModel({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.address,
    this.contact,
    this.description,
    this.image,
    required this.verified,
    required this.addedBy,
    required this.rating,
    required this.reviews,
    this.operatingHours,
    this.tags,
    required this.isActive,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UtilityModel.fromJson(Map<String, dynamic> json) {
    return UtilityModel(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      category: json['category'],
      latitude: (json['location']['coordinates'][1] as num).toDouble(),
      longitude: (json['location']['coordinates'][0] as num).toDouble(),
      address: json['location']?['address'],
      contact: json['contact'] != null ? Map<String, dynamic>.from(json['contact']) : null,
      description: json['description'],
      image: json['image'],
      verified: json['verified'] ?? false,
      addedBy: json['addedBy']?['name'] ?? json['addedBy']?['_id'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as List?)
          ?.map((r) => Review.fromJson(r))
          .toList() ?? [],
      operatingHours: json['operatingHours'] != null 
          ? Map<String, dynamic>.from(json['operatingHours']) 
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      isActive: json['isActive'] ?? true,
      rejectionReason: json['rejectionReason'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'category': category,
      'location': {
        'coordinates': [longitude, latitude],
        'address': address,
      },
      'contact': contact,
      'description': description,
      'image': image,
      'verified': verified,
      'addedBy': addedBy,
      'rating': rating,
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'operatingHours': operatingHours,
      'tags': tags,
      'isActive': isActive,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Review {
  final String userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? userName;

  Review({
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      userId: json['userId']?['_id'] ?? json['userId'] ?? '',
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      userName: json['userId']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
