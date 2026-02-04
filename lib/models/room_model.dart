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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}