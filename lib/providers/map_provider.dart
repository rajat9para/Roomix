import 'package:flutter/material.dart';
import 'package:roomix/models/map_marker_model.dart';
import 'package:roomix/services/map_service.dart';

class MapProvider extends ChangeNotifier {
  List<MapMarkerModel> _allMarkers = [];
  List<MapCluster> _clusters = [];
  List<MapMarkerModel> _filteredMarkers = [];
  double _centerLat = 28.5244;
  double _centerLng = 77.1855;
  int _zoomLevel = 14;
  bool _isLoading = false;
  String? _mapError;
  bool _mapUnavailable = false;
  String? _selectedMarkerId;
  Set<MarkerCategory> _selectedCategories = {
    MarkerCategory.pg,
    MarkerCategory.mess,
    MarkerCategory.service,
    MarkerCategory.event,
    MarkerCategory.utility,
  };

  // Getters
  List<MapMarkerModel> get allMarkers => _allMarkers;
  List<MapCluster> get clusters => _clusters;
  List<MapMarkerModel> get filteredMarkers => _filteredMarkers;
  double get centerLat => _centerLat;
  double get centerLng => _centerLng;
  int get zoomLevel => _zoomLevel;
  bool get isLoading => _isLoading;
  String? get mapError => _mapError;
  bool get mapUnavailable => _mapUnavailable;
  String? get selectedMarkerId => _selectedMarkerId;
  Set<MarkerCategory> get selectedCategories => _selectedCategories;

  MapMarkerModel? get selectedMarker {
    final markerId = _selectedMarkerId;
    if (markerId == null) {
      return null;
    }
    for (final marker in _allMarkers) {
      if (marker.id == markerId) {
        return marker;
      }
    }
    return null;
  }

  /// Initialize markers from API
  Future<void> initializeMarkers(
    List<MapMarkerModel> markers,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allMarkers = markers;
      _applyFilters();
      _clusterMarkers();
      // If MapMyIndia API key is missing, mark map unavailable
      if (!MapService.hasApiKey) {
        _mapUnavailable = true;
        _mapError = 'MapMyIndia API key not configured';
      } else {
        _mapUnavailable = false;
        _mapError = null;
      }
    } catch (e) {
      print('Error initializing markers: $e');
      _mapError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new marker
  void addMarker(MapMarkerModel marker) {
    _allMarkers.add(marker);
    _applyFilters();
    _clusterMarkers();
    notifyListeners();
  }

  /// Add multiple markers
  void addMarkers(List<MapMarkerModel> markers) {
    _allMarkers.addAll(markers);
    _applyFilters();
    _clusterMarkers();
    notifyListeners();
  }

  /// Remove a marker
  void removeMarker(String markerId) {
    _allMarkers.removeWhere((m) => m.id == markerId);
    if (_selectedMarkerId == markerId) {
      _selectedMarkerId = null;
    }
    _applyFilters();
    _clusterMarkers();
    notifyListeners();
  }

  /// Filter markers by category
  void toggleCategory(MarkerCategory category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    _applyFilters();
    _clusterMarkers();
    notifyListeners();
  }

  /// Set selected categories directly
  void setCategories(Set<MarkerCategory> categories) {
    _selectedCategories = categories;
    _applyFilters();
    _clusterMarkers();
    notifyListeners();
  }

  /// Search markers by title or description
  Future<void> searchMarkers(String query) async {
    if (query.isEmpty) {
      _applyFilters();
    } else {
      _filteredMarkers = _allMarkers
          .where((m) =>
              (m.title.toLowerCase().contains(query.toLowerCase()) ||
                  (m.description?.toLowerCase().contains(query.toLowerCase()) ??
                      false)) &&
              _selectedCategories.contains(m.category))
          .toList();
    }
    _clusterMarkers();
    notifyListeners();
  }

  /// Select a marker
  void selectMarker(String markerId) {
    _selectedMarkerId = markerId;
    notifyListeners();
  }

  /// Update map center and zoom
  void updateMapView(
    double lat,
    double lng,
    int zoom,
  ) {
    _centerLat = lat;
    _centerLng = lng;
    _zoomLevel = zoom;
    notifyListeners();
  }

  /// Get nearby markers within radius (in km)
  List<MapMarkerModel> getNearbyMarkers(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
  }) {
    return _filteredMarkers.where((marker) {
      final distance = MapService.calculateDistanceKm(
        latitude,
        longitude,
        marker.latitude,
        marker.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  /// Return a map image URL or the asset placeholder if map is unavailable.
  String getMapImageUrl({int width = 1200, int height = 1600}) {
    try {
      if (!MapService.hasApiKey) return MapService.placeholderAsset;
      final markers = _filteredMarkers.length > 20 ? _filteredMarkers.take(20).toList() : _filteredMarkers;
      final url = MapService.generateStaticMapUrl(
        centerLat: _centerLat,
        centerLng: _centerLng,
        zoomLevel: _zoomLevel,
        width: width,
        height: height,
        markers: markers,
      );
      if (url.isEmpty) return MapService.placeholderAsset;
      return url;
    } catch (e) {
      _mapError = e.toString();
      _mapUnavailable = true;
      notifyListeners();
      return MapService.placeholderAsset;
    }
  }

  void clearMapError() {
    _mapError = null;
    _mapUnavailable = false;
    notifyListeners();
  }

  /// Apply category filters
  void _applyFilters() {
    _filteredMarkers = _allMarkers
        .where((m) => _selectedCategories.contains(m.category))
        .toList();
  }

  /// Cluster markers
  void _clusterMarkers() {
    _clusters = MapService.clusterMarkers(_filteredMarkers);
  }

  /// Clear all markers
  void clearMarkers() {
    _allMarkers.clear();
    _filteredMarkers.clear();
    _clusters.clear();
    _selectedMarkerId = null;
    notifyListeners();
  }

  /// Reset to default view
  void resetView() {
    _centerLat = 28.5244;
    _centerLng = 77.1855;
    _zoomLevel = 14;
    _selectedMarkerId = null;
    _selectedCategories = {
      MarkerCategory.pg,
      MarkerCategory.mess,
      MarkerCategory.service,
      MarkerCategory.event,
      MarkerCategory.utility,
    };
    _applyFilters();
    _clusterMarkers();
    notifyListeners();
  }
}
