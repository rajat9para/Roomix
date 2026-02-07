import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:roomix/models/map_marker_model.dart';

class MapService {
  /// MapMyIndia API key loaded from compile-time constants
  /// 
  /// Priority order:
  /// 1. `MAPMYINDIA_API_KEY` passed via `--dart-define` at build time
  /// 2. (No fallback shipped) — if not provided, the getter returns an empty string
  /// 
  /// To provide the key at build time:
  /// - Flutter (recommended): `flutter run --dart-define=MAPMYINDIA_API_KEY=your_key`
  /// - Android: `flutter build apk --dart-define=MAPMYINDIA_API_KEY=your_key`
  /// 
  /// Get your API key from: https://www.mapmyindia.com/
  static const String _envKey = String.fromEnvironment('MAPMYINDIA_API_KEY');
  // Intentionally no hardcoded fallback key in repository. If no dart-define is
  // provided, the getter returns an empty string so no key is shipped in builds.
  // A runtime override is supported for developer testing only (stored in
  // `MapService.runtimeKey`) and is not persisted to compiled builds.
  static String? runtimeKey;

  static String get mapmyindiaApiKey {
    // Runtime override takes precedence for local testing
    if (runtimeKey != null && runtimeKey!.isNotEmpty) {
      debugPrint('MapService: using runtime MapMyIndia API key override');
      return runtimeKey!;
    }

    if (_envKey.isNotEmpty) return _envKey;

    // In debug builds, surface an assertion to help developers remember to set the key.
    assert(() {
      // This message appears only in debug mode.
      // You can set the key with: flutter run --dart-define=MAPMYINDIA_API_KEY=your_key
      // or via CI/CD environment variables.
      // ignore: avoid_print
      print('Warning: MAPMYINDIA_API_KEY not provided; map features will be disabled.');
      return true;
    }());

    return '';
  }
  
  static const String mapmyindiaBaseUrl = 'https://apis.mapmyindia.com/advancedmaps/v1/staticimage';

  /// Local placeholder asset to show when maps are unavailable.
  static const String placeholderAsset = 'assets/images/NEW_LOGO.png';


  // Generate static map image URL with markers
  static String generateStaticMapUrl({
    required double centerLat,
    required double centerLng,
    required int zoomLevel,
    required int width,
    required int height,
    List<MapMarkerModel>? markers,
  }) {
    if (mapmyindiaApiKey.isEmpty) {
      debugPrint('MapService: MAPMYINDIA_API_KEY is empty; not generating map URL');
      return '';
    }
    final buffer = StringBuffer('$mapmyindiaBaseUrl?');

    buffer.write('center=${centerLng.toStringAsFixed(6)},${centerLat.toStringAsFixed(6)}');
    buffer.write('&zoom=$zoomLevel');
    buffer.write('&size=${width}x${height}');

    // Add markers if provided (MapMyIndia format: lng,lat)
    if (markers != null && markers.isNotEmpty) {
      final markerParts = markers
          .map((marker) =>
              '${marker.longitude.toStringAsFixed(6)},${marker.latitude.toStringAsFixed(6)}')
          .toList();
      final markerParam = markerParts.join(';');
      buffer.write('&markers=$markerParam');
    }

    buffer.write('&key=$mapmyindiaApiKey');

    return buffer.toString();
  }

  /// Convenience: returns true if a key is available (env or runtime override)
  static bool get hasApiKey => mapmyindiaApiKey.isNotEmpty;

  /// Lightweight preview URL without markers (faster and more reliable)
  static String generatePreviewUrl({
    required double centerLat,
    required double centerLng,
    int zoomLevel = 14,
    int width = 600,
    int height = 300,
  }) {
    if (mapmyindiaApiKey.isEmpty) {
      return '';
    }
    return '$mapmyindiaBaseUrl?center=${centerLng.toStringAsFixed(6)},${centerLat.toStringAsFixed(6)}'
        '&zoom=$zoomLevel&size=${width}x${height}&key=$mapmyindiaApiKey';
  }

  // Search for locations by query
  static Future<List<Map<String, dynamic>>> searchLocations(
    String query, {
    required double latitude,
    required double longitude,
    double radiusInMeters = 50000,
  }) async {
    if (mapmyindiaApiKey.isEmpty) {
      debugPrint('MapService.searchLocations: MAPMYINDIA_API_KEY missing; returning empty results');
      return [];
    }

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://atlas.mapmyindia.com/api/places/textsearch/json',
        queryParameters: {
          'query': query,
          'location': '$latitude,$longitude',
          'region': 'IND',
          'key': mapmyindiaApiKey,
        },
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List?;
        return results?.map((r) => r as Map<String, dynamic>).toList() ?? [];
      }
      return [];
    } catch (e) {
      debugPrint('Error searching locations: $e');
      return [];
    }
  }

  // Reverse geocoding - get address from coordinates
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    if (mapmyindiaApiKey.isEmpty) {
      debugPrint('MapService.getAddressFromCoordinates: MAPMYINDIA_API_KEY missing; skipping request');
      return null;
    }

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://atlas.mapmyindia.com/api/places/reverse/json',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'key': mapmyindiaApiKey,
        },
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          return results[0]['formatted_address'] ?? 'Unknown location';
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting address: $e');
      return null;
    }
  }

  // Forward geocoding - get coordinates from address
  static Future<Map<String, double>?> getCoordinatesFromAddress(
    String address,
  ) async {
    if (mapmyindiaApiKey.isEmpty) {
      debugPrint('MapService.getCoordinatesFromAddress: MAPMYINDIA_API_KEY missing; skipping request');
      return null;
    }

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://atlas.mapmyindia.com/api/places/geocode/json',
        queryParameters: {
          'address': address,
          'key': mapmyindiaApiKey,
        },
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          final geometry = results[0]['geometry'] as Map<String, dynamic>?;
          if (geometry != null) {
            final location = geometry['location'] as Map<String, dynamic>?;
            if (location != null) {
              return {
                'latitude': (location['lat'] as num).toDouble(),
                'longitude': (location['lng'] as num).toDouble(),
              };
            }
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
      return null;
    }
  }

  // Calculate simple clustering based on proximity
  static List<MapCluster> clusterMarkers(
    List<MapMarkerModel> markers, {
    double clusterRadiusKm = 1.0,
  }) {
    if (markers.isEmpty) return [];

    final clusters = <MapCluster>[];
    final processed = <String>{};

    for (final marker in markers) {
      if (processed.contains(marker.id)) continue;

      final clusterMarkers = [marker];
      final clusterLatSum = marker.latitude;
      final clusterLngSum = marker.longitude;

      // Find nearby markers
      for (final other in markers) {
        if (other.id == marker.id || processed.contains(other.id)) continue;

        final distance = calculateDistanceKm(
          marker.latitude,
          marker.longitude,
          other.latitude,
          other.longitude,
        );

        if (distance <= clusterRadiusKm) {
          clusterMarkers.add(other);
          processed.add(other.id);
        }
      }

      // Calculate cluster center
      final avgLat = clusterMarkers.fold<double>(
            0,
            (sum, m) => sum + m.latitude,
          ) /
          clusterMarkers.length;
      final avgLng = clusterMarkers.fold<double>(
            0,
            (sum, m) => sum + m.longitude,
          ) /
          clusterMarkers.length;

      clusters.add(
        MapCluster(
          latitude: avgLat,
          longitude: avgLng,
          markerCount: clusterMarkers.length,
          markers: clusterMarkers,
        ),
      );

      processed.add(marker.id);
    }

    return clusters;
  }

  /// Calculate distance between two coordinates in kilometers using Haversine formula
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
