import 'package:flutter/material.dart';
import 'package:roomix/models/utility_model.dart';
import 'package:roomix/models/map_marker_model.dart';
import 'package:roomix/services/api_service.dart';

class UtilityProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<UtilityModel> _utilities = [];
  List<UtilityModel> _filteredUtilities = [];
  UtilityModel? _selectedUtility;
  String? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  List<UtilityModel> get utilities => _utilities;
  List<UtilityModel> get filteredUtilities => _filteredUtilities;
  UtilityModel? get selectedUtility => _selectedUtility;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final List<String> categories = [
    'All',
    'medical',
    'grocery',
    'xerox',
    'stationary',
    'pharmacy',
    'cafe',
    'laundry',
    'salon',
    'bank',
    'atm',
    'restaurant',
    'other'
  ];

  // Get all utilities
  Future<void> fetchUtilities({String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final utilities = await ApiService.getUtilities(category: category);
      _utilities = utilities;
      _filteredUtilities = utilities;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get utilities by category
  Future<void> getUtilitiesByCategory(String category) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedCategory = category == 'All' ? null : category;
    notifyListeners();

    try {
      if (category == 'All') {
        _filteredUtilities = _utilities;
      } else {
        final utilities = await ApiService.getUtilitiesByCategory(category);
        _filteredUtilities = utilities;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get utilities within radius
  Future<void> getUtilitiesNearby(
    double latitude,
    double longitude, {
    int radiusMeters = 5000,
    String? category,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final utilities = await ApiService.getUtilitiesNearby(
        latitude,
        longitude,
        radiusMeters: radiusMeters,
        category: category,
      );
      _utilities = utilities;
      _filteredUtilities = utilities;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Search utilities
  Future<void> searchUtilities(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (query.isEmpty) {
        _filteredUtilities = _utilities;
      } else {
        final utilities = await ApiService.searchUtilities(query);
        _filteredUtilities = utilities;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get single utility
  Future<void> getUtility(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final utility = await ApiService.getUtility(id);
      _selectedUtility = utility;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Create utility
  Future<UtilityModel> createUtility({
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    String? address,
    Map<String, dynamic>? contact,
    String? description,
    String? image,
    List<String>? tags,
    Map<String, dynamic>? operatingHours,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final utility = await ApiService.createUtility(
        name: name,
        category: category,
        latitude: latitude,
        longitude: longitude,
        address: address,
        contact: contact,
        description: description,
        image: image,
        tags: tags,
        operatingHours: operatingHours,
      );
      _utilities.add(utility);
      _filteredUtilities.add(utility);
      _isLoading = false;
      notifyListeners();
      return utility;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update utility
  Future<UtilityModel> updateUtility(
    String id, {
    String? name,
    String? category,
    double? latitude,
    double? longitude,
    String? address,
    Map<String, dynamic>? contact,
    String? description,
    String? image,
    List<String>? tags,
    Map<String, dynamic>? operatingHours,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final utility = await ApiService.updateUtility(
        id,
        name: name,
        category: category,
        latitude: latitude,
        longitude: longitude,
        address: address,
        contact: contact,
        description: description,
        image: image,
        tags: tags,
        operatingHours: operatingHours,
      );

      final index = _utilities.indexWhere((u) => u.id == id);
      if (index != -1) {
        _utilities[index] = utility;
        _filteredUtilities = _utilities;
      }

      _isLoading = false;
      notifyListeners();
      return utility;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete utility
  Future<void> deleteUtility(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.deleteUtility(id);
      _utilities.removeWhere((u) => u.id == id);
      _filteredUtilities.removeWhere((u) => u.id == id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add review to utility
  Future<UtilityModel> addReview(
    String utilityId, {
    required int rating,
    String? comment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final utility = await ApiService.addReviewToUtility(
        utilityId,
        rating: rating,
        comment: comment,
      );

      final index = _utilities.indexWhere((u) => u.id == utilityId);
      if (index != -1) {
        _utilities[index] = utility;
        _filteredUtilities = _utilities;
      }

      if (_selectedUtility?.id == utilityId) {
        _selectedUtility = utility;
      }

      _isLoading = false;
      notifyListeners();
      return utility;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Clear selected utility
  void clearSelected() {
    _selectedUtility = null;
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _selectedCategory = null;
    _filteredUtilities = _utilities;
    notifyListeners();
  }

  // Admin: Get all utilities (including unverified)
  Future<void> getAllUtilitiesAdmin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final utilities = await ApiService.getAllUtilitiesAdmin();
      _utilities = utilities;
      _filteredUtilities = utilities;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Admin: Get pending utilities
  Future<void> getPendingUtilitiesAdmin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final utilities = await ApiService.getPendingUtilities();
      _utilities = utilities;
      _filteredUtilities = utilities;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Admin: Verify utility
  Future<UtilityModel> verifyUtility(String utilityId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final utility = await ApiService.verifyUtility(utilityId);

      final index = _utilities.indexWhere((u) => u.id == utilityId);
      if (index != -1) {
        _utilities[index] = utility;
        _filteredUtilities = _utilities;
      }

      if (_selectedUtility?.id == utilityId) {
        _selectedUtility = utility;
      }

      _isLoading = false;
      notifyListeners();
      return utility;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Admin: Reject utility
  Future<UtilityModel> rejectUtility(String utilityId, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final utility = await ApiService.rejectUtility(utilityId, reason: reason);

      final index = _utilities.indexWhere((u) => u.id == utilityId);
      if (index != -1) {
        _utilities[index] = utility;
        _filteredUtilities = _utilities;
      }

      if (_selectedUtility?.id == utilityId) {
        _selectedUtility = utility;
      }

      _isLoading = false;
      notifyListeners();
      return utility;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Convert utilities to map markers for campus map integration
  List<MapMarkerModel> getUtilitiesAsMapMarkers() {
    return _filteredUtilities
        .where((utility) => utility.verified) // Only show verified utilities on map
        .map((utility) => MapMarkerModel(
              id: utility.id,
              title: utility.name,
              description: utility.description,
              latitude: utility.latitude,
              longitude: utility.longitude,
              category: MarkerCategory.utility,
              imageUrl: utility.image,
              address: utility.address,
              metadata: utility,
            ))
        .toList();
  }
}
