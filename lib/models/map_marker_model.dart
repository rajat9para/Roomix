import 'package:flutter/material.dart';

enum MarkerCategory {
  pg,
  mess,
  service,
  event,
  utility,
}

class MapMarkerModel {
  final String id;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final MarkerCategory category;
  final String? imageUrl;
  final String? address;
  final dynamic metadata; // Store additional data (Room, Mess, etc.)

  MapMarkerModel({
    required this.id,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.imageUrl,
    this.address,
    this.metadata,
  });

  Color getCategoryColor() {
    switch (category) {
      case MarkerCategory.pg:
        return const Color(0xFF3B82F6);
      case MarkerCategory.mess:
        return const Color(0xFF10B981);
      case MarkerCategory.service:
        return const Color(0xFFF59E0B);
      case MarkerCategory.event:
        return const Color(0xFF8B5CF6);
      case MarkerCategory.utility:
        return const Color(0xFF06B6D4);
    }
  }

  IconData getCategoryIcon() {
    switch (category) {
      case MarkerCategory.pg:
        return Icons.home_work_rounded;
      case MarkerCategory.mess:
        return Icons.restaurant_rounded;
      case MarkerCategory.service:
        return Icons.build_rounded;
      case MarkerCategory.event:
        return Icons.event_rounded;
      case MarkerCategory.utility:
        return Icons.miscellaneous_services_rounded;
    }
  }

  String getCategoryName() {
    switch (category) {
      case MarkerCategory.pg:
        return 'Room / PG';
      case MarkerCategory.mess:
        return 'Mess';
      case MarkerCategory.service:
        return 'Service';
      case MarkerCategory.event:
        return 'Event';
      case MarkerCategory.utility:
        return 'Utility';
    }
  }
}

class MapCluster {
  final double latitude;
  final double longitude;
  final int markerCount;
  final List<MapMarkerModel> markers;

  MapCluster({
    required this.latitude,
    required this.longitude,
    required this.markerCount,
    required this.markers,
  });
}
