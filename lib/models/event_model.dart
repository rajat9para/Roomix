class EventModel {
  final String id;
  final String title;
  final String description;
  final String? image;
  final DateTime eventDate;
  final String? location;
  final String? organizer;
  final String? contact;
  final List<String> tags;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.eventDate,
    this.location,
    this.organizer,
    this.contact,
    required this.tags,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      eventDate: DateTime.parse(json['eventDate']),
      location: json['location'],
      organizer: json['organizer'],
      contact: json['contact'],
      tags: List<String>.from(json['tags'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'image': image,
      'eventDate': eventDate.toIso8601String(),
      'location': location,
      'organizer': organizer,
      'contact': contact,
      'tags': tags,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
