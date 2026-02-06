import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class StorageUtil {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys for secure storage
  static const String _tokenKey = 'user_token';
  static const String _userKey = 'user_info';
  static const String _selectedUniversityKey = 'selected_university';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _campusLatKey = 'campus_latitude';
  static const String _campusLngKey = 'campus_longitude';
  static const String _campusAddressKey = 'campus_address';
  static const String _studentCourseKey = 'student_course';
  static const String _studentYearKey = 'student_year';
  static const String _studentCollegeKey = 'student_college';
  static const String _studentContactKey = 'student_contact';

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

  // Campus location methods
  Future<void> saveCampusLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    await _storage.write(key: _campusLatKey, value: latitude.toString());
    await _storage.write(key: _campusLngKey, value: longitude.toString());
    if (address != null) {
      await _storage.write(key: _campusAddressKey, value: address);
    }
  }

  Future<Map<String, dynamic>?> getCampusLocation() async {
    final lat = await _storage.read(key: _campusLatKey);
    final lng = await _storage.read(key: _campusLngKey);
    final address = await _storage.read(key: _campusAddressKey);
    if (lat == null || lng == null) {
      return null;
    }
    return {
      'latitude': double.tryParse(lat) ?? 0.0,
      'longitude': double.tryParse(lng) ?? 0.0,
      'address': address,
    };
  }

  Future<void> clearCampusLocation() async {
    await _storage.delete(key: _campusLatKey);
    await _storage.delete(key: _campusLngKey);
    await _storage.delete(key: _campusAddressKey);
  }

  // Student onboarding fields
  Future<void> saveStudentProfile({
    required String course,
    required String year,
    required String college,
    String? contact,
  }) async {
    await _storage.write(key: _studentCourseKey, value: course);
    await _storage.write(key: _studentYearKey, value: year);
    await _storage.write(key: _studentCollegeKey, value: college);
    if (contact != null) {
      await _storage.write(key: _studentContactKey, value: contact);
    }
  }

  Future<Map<String, String>?> getStudentProfile() async {
    final course = await _storage.read(key: _studentCourseKey);
    final year = await _storage.read(key: _studentYearKey);
    final college = await _storage.read(key: _studentCollegeKey);
    final contact = await _storage.read(key: _studentContactKey);
    if (course == null || year == null || college == null) {
      return null;
    }
    return {
      'course': course,
      'year': year,
      'college': college,
      if (contact != null) 'contact': contact,
    };
  }

  Future<void> clearStudentProfile() async {
    await _storage.delete(key: _studentCourseKey);
    await _storage.delete(key: _studentYearKey);
    await _storage.delete(key: _studentCollegeKey);
    await _storage.delete(key: _studentContactKey);
  }
}
