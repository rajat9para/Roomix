import 'package:flutter/material.dart';
import 'package:roomix/models/university_model.dart';
import 'package:roomix/services/api_service.dart';
import 'package:roomix/utils/storage_util.dart';

class UserPreferencesProvider extends ChangeNotifier {
  final StorageUtil _storageUtil = StorageUtil();
  UniversityModel? _selectedUniversity;
  bool _isOnboardingComplete = false;
  bool _isLoading = false;

  UniversityModel? get selectedUniversity => _selectedUniversity;
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isLoading => _isLoading;

  /// Load user preferences from local storage
  Future<void> loadUserPreferences() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedUniversityId = await _storageUtil.getSelectedUniversity();
      final onboardingComplete = await _storageUtil.getOnboardingComplete();

      _isOnboardingComplete = onboardingComplete;
      
      // If university ID is saved, fetch and set the university model
      if (savedUniversityId != null && savedUniversityId.isNotEmpty) {
        try {
          final university = await ApiService.getUniversityById(savedUniversityId);
          _selectedUniversity = university;
        } catch (e) {
          debugPrint('Error fetching saved university details: $e');
          // University ID saved but fetch failed - keep ID for reference
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set selected university and save to storage
  Future<void> setSelectedUniversity(UniversityModel university) async {
    _selectedUniversity = university;
    notifyListeners();

    try {
      await _storageUtil.saveSelectedUniversity(university.id);
    } catch (e) {
      debugPrint('Error saving university selection: $e');
    }
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    _isOnboardingComplete = true;
    notifyListeners();

    try {
      await _storageUtil.saveOnboardingComplete(true);
    } catch (e) {
      debugPrint('Error saving onboarding completion: $e');
    }
  }

  /// Clear user preferences
  Future<void> clearPreferences() async {
    _selectedUniversity = null;
    _isOnboardingComplete = false;
    notifyListeners();

    try {
      await _storageUtil.clearSelectedUniversity();
      await _storageUtil.clearOnboardingComplete();
    } catch (e) {
      debugPrint('Error clearing preferences: $e');
    }
  }

  /// Get selected university ID
  Future<String?> getSelectedUniversityId() async {
    return await _storageUtil.getSelectedUniversity();
  }
}
