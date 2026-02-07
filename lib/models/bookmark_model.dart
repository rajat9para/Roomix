class BookmarkModel {
  final String id;
  final String userId;
  final String itemId;
  final String type; // 'room', 'mess', 'utility', 'market', 'roommate', 'event'
  final String itemTitle;
  final String? itemImage;
  final double? itemPrice;
  final double? rating;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata; // Store full item data

  BookmarkModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.type,
    required this.itemTitle,
    this.itemImage,
    this.itemPrice,
    this.rating,
    required this.createdAt,
    this.metadata,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      itemId: json['itemId'] ?? '',
      type: json['type'] ?? 'room',
      itemTitle: json['itemTitle'] ?? '',
      itemImage: json['itemImage'],
      itemPrice: (json['itemPrice'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'itemId': itemId,
      'type': type,
      'itemTitle': itemTitle,
      'itemImage': itemImage,
      'itemPrice': itemPrice,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}
