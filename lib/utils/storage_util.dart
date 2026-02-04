import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class StorageUtil {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys for secure storage
  static const String _tokenKey = 'user_token';
  static const String _userKey = 'user_info';
  static const String _selectedUniversityKey = 'selected_university';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // University selection methods
  Future<void> saveSelectedUniversity(String universityId) async {
    await _storage.write(key: _selectedUniversityKey, value: universityId);
  }

  Future<String?> getSelectedUniversity() async {
    return await _storage.read(key: _selectedUniversityKey);
  }

  Future<void> clearSelectedUniversity() async {
    await _storage.delete(key: _selectedUniversityKey);
  }

  // Onboarding completion methods
  Future<void> saveOnboardingComplete(bool isComplete) async {
    await _storage.write(key: _onboardingCompleteKey, value: isComplete.toString());
  }

  Future<bool> getOnboardingComplete() async {
    final value = await _storage.read(key: _onboardingCompleteKey);
    return value?.toLowerCase() == 'true';
  }

  Future<void> clearOnboardingComplete() async {
    await _storage.delete(key: _onboardingCompleteKey);
  }
}