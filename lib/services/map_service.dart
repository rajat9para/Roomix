import 'dart:math';
import 'package:dio/dio.dart';
import 'package:roomix/models/map_marker_model.dart';

class MapService {
  // TomTom API key - use environment variable if set, otherwise use hardcoded key
  static const String _envKey = String.fromEnvironment('TOMTOM_API_KEY');
  static const String _fallbackKey = 'LQQ5FC01CqHB6TA6H1mL1aNjd9NWkfuZ';
  static String get tomtomApiKey => _envKey.isNotEmpty ? _envKey : _fallbackKey;
  static const String tomtomBaseUrl = 'https://api.tomtom.com/map/1/staticimage';


  // Generate static map image URL with markers
  static String generateStaticMapUrl({
    required double centerLat,
    required double centerLng,
    required int zoomLevel,
    required int width,
    required int height,
    List<MapMarkerModel>? markers,
  }) {
    if (tomtomApiKey.isEmpty) {
      return '';
    }
    final buffer = StringBuffer('$tomtomBaseUrl?');

    buffer.write('center=${centerLng.toStringAsFixed(6)},${centerLat.toStringAsFixed(6)}');
    buffer.write('&zoom=$zoomLevel');
    buffer.write('&format=png');
    buffer.write('&width=$width');
    buffer.write('&height=$height');

    // Add markers if provided (single markers param with pipe-delimited coords)
    if (markers != null && markers.isNotEmpty) {
      final markerParts = markers
          .map((marker) =>
              '${marker.longitude.toStringAsFixed(6)},${marker.latitude.toStringAsFixed(6)}')
          .toList();
      final markerParam = Uri.encodeComponent(markerParts.join('|'));
      buffer.write('&markers=$markerParam');
    }

    buffer.write('&key=$tomtomApiKey');

    return buffer.toString();
  }

  /// Lightweight preview URL without markers (faster and more reliable)
  static String generatePreviewUrl({
    required double centerLat,
    required double centerLng,
    int zoomLevel = 14,
    int width = 600,
    int height = 300,
  }) {
    if (tomtomApiKey.isEmpty) {
      return '';
    }
    return '$tomtomBaseUrl?center=${centerLng.toStringAsFixed(6)},${centerLat.toStringAsFixed(6)}'
        '&zoom=$zoomLevel&format=png&width=$width&height=$height&key=$tomtomApiKey';
  }

  // Search for locations by query
  static Future<List<Map<String, dynamic>>> searchLocations(
    String query, {
    required double latitude,
    required double longitude,
    double radiusInMeters = 50000,
  }) async {
    try {
      final dio = Dio();
      final encodedQuery = Uri.encodeComponent(query);
      final response = await dio.get(
        'https://api.tomtom.com/search/2/search/$encodedQuery.json',
        queryParameters: {
          'key': tomtomApiKey,
          'lat': latitude,
          'lon': longitude,
          'radiusMeters': radiusInMeters,
        },
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        return results.map((r) => r as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  // Reverse geocoding - get address from coordinates
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.tomtom.com/search/2/reverseGeocode/${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}.json',
        queryParameters: {
          'key': tomtomApiKey,
        },
      );

      if (response.statusCode == 200) {
        final results = response.data['addresses'] as List;
        if (results.isNotEmpty) {
          return results[0]['address']['freeformAddress'] ?? 'Unknown location';
        }
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  // Forward geocoding - get coordinates from address
  static Future<Map<String, double>?> getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      final dio = Dio();
      final encodedAddress = Uri.encodeComponent(address);
      final response = await dio.get(
        'https://api.tomtom.com/search/2/geocode/$encodedAddress.json',
        queryParameters: {
          'key': tomtomApiKey,
        },
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        if (results.isNotEmpty) {
          final position = results[0]['position'] as Map<String, dynamic>;
          return {
            'latitude': (position['lat'] as num).toDouble(),
            'longitude': (position['lon'] as num).toDouble(),
          };
        }
      }
      return null;
    } catch (e) {
      print('Error getting coordinates: $e');
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
