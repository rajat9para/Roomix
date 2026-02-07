class RoomModel {
  final String id;
  final String title;
  final String location;
  final double price;
  final String type;
  final String image;
  final String contact;
  final double? latitude;
  final double? longitude;
  final List<String> amenities;
  final bool verified;
  final double rating;
  final List<RoomReview> reviews;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoomModel({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.type,
    required this.image,
    required this.contact,
    this.latitude,
    this.longitude,
    required this.amenities,
    this.verified = false,
    this.rating = 0.0,
    this.reviews = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      location: json['location'],
      price: (json['price'] as num).toDouble(),
      type: json['type'],
      image: json['image'],
      contact: json['contact'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      amenities: List<String>.from(json['amenities'] ?? []),
      verified: json['verified'] ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as List?)
          ?.map((r) => RoomReview.fromJson(r))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'location': location,
      'price': price,
      'type': type,
      'image': image,
      'contact': contact,
      'latitude': latitude,
      'longitude': longitude,
      'amenities': amenities,
      'verified': verified,
      'rating': rating,
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class RoomReview {
  final String? id;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  RoomReview({
    this.id,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory RoomReview.fromJson(Map<String, dynamic> json) {
    return RoomReview(
      id: json['_id'],
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
