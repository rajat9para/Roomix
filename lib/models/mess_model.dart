class MessModel {
  final String id;
  final String name;
  final String? image;
  final double price;
  final String? address;
  final String? contact;
  final String? specialization;
  final List<String>? specialities;
  final String? openingTime;
  final String? closingTime;
  final String? timings;
  final String? menuPreview;
  final bool isActive;
  final double rating;
  final double? latitude;
  final double? longitude;
  final List<MessReview> reviews;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessModel({
    required this.id,
    required this.name,
    this.image,
    required this.price,
    this.address,
    this.contact,
    this.specialization,
    this.specialities,
    this.openingTime,
    this.closingTime,
    this.timings,
    this.menuPreview,
    required this.isActive,
    required this.rating,
    this.latitude,
    this.longitude,
    required this.reviews,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessModel.fromJson(Map<String, dynamic> json) {
    final rawTimings = json['timings'] as String?;
    final rawOpeningTime = json['openingTime'] as String?;
    final rawClosingTime = json['closingTime'] as String?;
    String? openingTime = rawOpeningTime;
    String? closingTime = rawClosingTime;

    if (openingTime == null && closingTime == null && rawTimings != null) {
      final parts = rawTimings.split('-');
      if (parts.length >= 2) {
        openingTime = parts[0].trim();
        closingTime = parts[1].trim();
      }
    }

    final priceValue = json['price'] ?? json['monthlyPrice'];

    return MessModel(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      image: json['image'],
      price: (priceValue as num?)?.toDouble() ?? 0.0,
      address: json['address'],
      contact: json['contact'],
      specialization: json['specialization'],
      specialities: List<String>.from(json['specialities'] ?? []),
      openingTime: openingTime,
      closingTime: closingTime,
      timings: rawTimings,
      menuPreview: json['menuPreview'],
      isActive: json['isActive'] ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      reviews: (json['reviews'] as List?)
          ?.map((r) => MessReview.fromJson(r))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'price': price,
      'address': address,
      'contact': contact,
      'specialization': specialization,
      'specialities': specialities,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'timings': timings,
      'menuPreview': menuPreview,
      'isActive': isActive,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class MessReview {
  final String userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  MessReview({
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory MessReview.fromJson(Map<String, dynamic> json) {
    return MessReview(
      userId: json['userId']?['_id'] ?? json['userId'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
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
