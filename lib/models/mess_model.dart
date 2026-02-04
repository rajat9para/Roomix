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
  final bool isActive;
  final double rating;
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
    required this.isActive,
    required this.rating,
    required this.reviews,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessModel.fromJson(Map<String, dynamic> json) {
    return MessModel(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      image: json['image'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      address: json['address'],
      contact: json['contact'],
      specialization: json['specialization'],
      specialities: List<String>.from(json['specialities'] ?? []),
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      isActive: json['isActive'] ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
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
      'isActive': isActive,
      'rating': rating,
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
