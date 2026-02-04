import 'package:dio/dio.dart';
import 'package:roomix/models/university_model.dart';
import 'package:roomix/models/utility_model.dart';
import 'package:roomix/utils/storage_util.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  static late StorageUtil _storageUtil;
  
  // Initialize Dio eagerly with base options, will add interceptors in initialize()
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ),
  );

  static void initialize() {
    _storageUtil = StorageUtil();
    
    // Add interceptors for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageUtil.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors globally
          if (error.response?.statusCode == 401) {
            // Token expired, logout user
            _storageUtil.clearToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  static Dio get dio => _dio;

  // Auth endpoints
  static Future<Map<String, dynamic>> login(String email, String password, String role) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
        'role': role,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  // Firebase Google Auth endpoint
  static Future<Map<String, dynamic>> googleAuth({
    required String idToken,
    required String email,
    required String name,
    String? photoUrl,
    required String role,
  }) async {
    try {
      final response = await dio.post('/auth/google', data: {
        'idToken': idToken,
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'role': role,
      });
      return response.data;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Google authentication failed';
      throw Exception(message);
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await dio.post('/auth/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'OTP verification failed');
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    try {
      final response = await dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }

  // Password Recovery: Send OTP
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await dio.post('/auth/forgot-password', data: {
        'email': email,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to send password reset OTP');
    }
  }

  // Password Recovery: Verify Reset OTP
  static Future<Map<String, dynamic>> verifyResetOtp(String email, String otp) async {
    try {
      final response = await dio.post('/auth/verify-reset-otp', data: {
        'email': email,
        'otp': otp,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'OTP verification failed');
    }
  }

  // Password Recovery: Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await dio.post('/auth/reset-password', data: {
        'email': email,
        'resetToken': resetToken,
        'newPassword': newPassword,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to reset password');
    }
  }

  // Profile endpoints
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await dio.get('/profile');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch profile');
    }
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await dio.put('/profile', data: updates);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update profile');
    }
  }

  static Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> settings) async {
    try {
      final response = await dio.put('/profile/settings', data: settings);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update settings');
    }
  }

  static Future<Map<String, dynamic>> uploadProfilePicture(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: 'profile.jpg'),
      });
      final response = await dio.post('/profile/upload', data: formData);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to upload profile picture');
    }
  }

  // Room endpoints
  static Future<List<dynamic>> getRooms() async {
    try {
      final response = await dio.get('/rooms');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to fetch rooms');
    }
  }

  static Future<Map<String, dynamic>> createRoom(Map<String, dynamic> roomData) async {
    try {
      final response = await dio.post('/rooms', data: roomData);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to create room listing');
    }
  }

  // Mess endpoints
  static Future<Map<String, dynamic>> getMessMenu({int page = 1}) async {
    try {
      final response = await dio.get('/mess', queryParameters: {'page': page, 'limit': 10});
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to fetch mess menu');
    }
  }

  // Lost & Found endpoints
  static Future<Map<String, dynamic>> getLostItems({int page = 1}) async {
    try {
      final response = await dio.get('/lost', queryParameters: {'page': page, 'limit': 10});
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to fetch lost items');
    }
  }

  static Future<Map<String, dynamic>> createLostItem(Map<String, dynamic> itemData) async {
    try {
      final response = await dio.post('/lost', data: itemData);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to create lost item');
    }
  }

  // Events endpoints
  static Future<Map<String, dynamic>> getEvents({int page = 1}) async {
    try {
      final response = await dio.get('/events', queryParameters: {'page': page, 'limit': 10});
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to fetch events');
    }
  }

  // Market endpoints
  static Future<Map<String, dynamic>> getMarketItems({int page = 1}) async {
    try {
      final response = await dio.get('/market', queryParameters: {'page': page, 'limit': 10});
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to fetch market items');
    }
  }

  static Future<Map<String, dynamic>> createMarketItem(Map<String, dynamic> itemData) async {
    try {
      final response = await dio.post('/market', data: itemData);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to create market item');
    }
  }

  // University endpoints - Onboarding
  static Future<List<UniversityModel>> getAllUniversities() async {
    try {
      final response = await dio.get('/universities');
      final dataList = response.data['data'] as List;
      return dataList.map((json) => UniversityModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch universities');
    }
  }

  static Future<List<UniversityModel>> searchUniversities(String query) async {
    try {
      final response = await dio.get('/universities/search', queryParameters: {
        'query': query,
      });
      final dataList = response.data['data'] as List;
      return dataList.map((json) => UniversityModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to search universities');
    }
  }

  static Future<List<UniversityModel>> getNearbyUniversities({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
  }) async {
    try {
      final response = await dio.get('/universities/nearby', queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radiusKm': radiusKm,
      });
      final dataList = response.data['data'] as List;
      return dataList.map((json) => UniversityModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch nearby universities');
    }
  }

  static Future<UniversityModel> getUniversityById(String id) async {
    try {
      final response = await dio.get('/universities/$id');
      return UniversityModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to fetch university');
    }
  }

  // Roommate endpoints
  static Future<Map<String, dynamic>> createRoommateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await dio.post('/roommates/profile', data: profileData);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create profile');
    }
  }

  static Future<Map<String, dynamic>> getMyRoommateProfile() async {
    try {
      final response = await dio.get('/roommates/profile');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch profile');
    }
  }

  static Future<Map<String, dynamic>> getAllRoommateProfiles() async {
    try {
      final response = await dio.get('/roommates/all');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch profiles');
    }
  }

  static Future<Map<String, dynamic>> getRoommateProfileById(String userId) async {
    try {
      final response = await dio.get('/roommates/profile/$userId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch profile');
    }
  }

  static Future<Map<String, dynamic>> getRoommateMatches() async {
    try {
      final response = await dio.get('/roommates/matches');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch matches');
    }
  }

  static Future<Map<String, dynamic>> deleteRoommateProfile() async {
    try {
      final response = await dio.delete('/roommates/profile');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete profile');
    }
  }

  // Chat endpoints
  static Future<Map<String, dynamic>> sendChatMessage(String receiverId, String message) async {
    try {
      final response = await dio.post('/chat/send', data: {
        'receiver': receiverId,
        'message': message,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to send message');
    }
  }

  static Future<Map<String, dynamic>> getChatMessages(String conversationId) async {
    try {
      final response = await dio.get('/chat/messages/$conversationId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch messages');
    }
  }

  static Future<Map<String, dynamic>> getChatConversations() async {
    try {
      final response = await dio.get('/chat/conversations');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch conversations');
    }
  }

  static Future<Map<String, dynamic>> markChatAsRead(String conversationId) async {
    try {
      final response = await dio.put('/chat/read/$conversationId', data: {});
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to mark as read');
    }
  }

  static Future<Map<String, dynamic>> deleteChatMessage(String messageId) async {
    try {
      final response = await dio.delete('/chat/message/$messageId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete message');
    }
  }

  // Utility endpoints
  static Future<List<UtilityModel>> getUtilities({String? category}) async {
    try {
      final response = await dio.get('/utilities', queryParameters: {
        if (category != null) 'category': category,
      });
      final dataList = response.data is List ? response.data : response.data['data'] as List;
      return dataList.map((json) => UtilityModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch utilities');
    }
  }

  static Future<UtilityModel> getUtility(String id) async {
    try {
      final response = await dio.get('/utilities/$id');
      return UtilityModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch utility');
    }
  }

  static Future<UtilityModel> createUtility({
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
    try {
      final response = await dio.post('/utilities', data: {
        'name': name,
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'contact': contact,
        'description': description,
        'image': image,
        'tags': tags,
        'operatingHours': operatingHours,
      });
      return UtilityModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create utility');
    }
  }

  static Future<UtilityModel> updateUtility(
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
    try {
      final response = await dio.put('/utilities/$id', data: {
        if (name != null) 'name': name,
        if (category != null) 'category': category,
        if (latitude != null && longitude != null) ...{
          'latitude': latitude,
          'longitude': longitude,
        },
        if (address != null) 'address': address,
        if (contact != null) 'contact': contact,
        if (description != null) 'description': description,
        if (image != null) 'image': image,
        if (tags != null) 'tags': tags,
        if (operatingHours != null) 'operatingHours': operatingHours,
      });
      return UtilityModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update utility');
    }
  }

  static Future<void> deleteUtility(String id) async {
    try {
      await dio.delete('/utilities/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete utility');
    }
  }

  static Future<UtilityModel> addReviewToUtility(
    String utilityId, {
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await dio.post('/utilities/$utilityId/review', data: {
        'rating': rating,
        if (comment != null) 'comment': comment,
      });
      return UtilityModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to add review');
    }
  }

  static Future<List<UtilityModel>> getUtilitiesByCategory(String category) async {
    try {
      final response = await dio.get('/utilities/category/$category');
      final dataList = response.data is List ? response.data : response.data['data'] as List;
      return dataList.map((json) => UtilityModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch utilities by category');
    }
  }

  static Future<List<UtilityModel>> searchUtilities(String query) async {
    try {
      final response = await dio.get('/utilities/search/$query');
      final dataList = response.data is List ? response.data : response.data['data'] as List;
      return dataList.map((json) => UtilityModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to search utilities');
    }
  }

  static Future<List<UtilityModel>> getUtilitiesNearby(
    double latitude,
    double longitude, {
    int radiusMeters = 5000,
    String? category,
  }) async {
    try {
      final response = await dio.get('/utilities', queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radiusMeters,
        if (category != null) 'category': category,
      });
      final dataList = response.data is List ? response.data : response.data['data'] as List;
      return dataList.map((json) => UtilityModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch nearby utilities');
    }
  }

  // Admin utility endpoints
  static Future<List<UtilityModel>> getAllUtilitiesAdmin() async {
    try {
      final response = await dio.get('/utilities/admin/all');
      final dataList = response.data is List ? response.data : response.data['data'] as List;
      return dataList.map((json) => UtilityModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch all utilities');
    }
  }

  static Future<List<UtilityModel>> getPendingUtilities() async {
    try {
      final response = await dio.get('/utilities/admin/pending');
      final dataList = response.data is List ? response.data : response.data['data'] as List;
      return dataList.map((json) => UtilityModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch pending utilities');
    }
  }

  static Future<UtilityModel> verifyUtility(String utilityId) async {
    try {
      final response = await dio.put('/utilities/admin/$utilityId/verify');
      return UtilityModel.fromJson(response.data['utility']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to verify utility');
    }
  }

  static Future<UtilityModel> rejectUtility(String utilityId, {String? reason}) async {
    try {
      final response = await dio.put('/utilities/admin/$utilityId/reject', data: {
        if (reason != null) 'reason': reason,
      });
      return UtilityModel.fromJson(response.data['utility']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to reject utility');
    }
  }

  // Generic HTTP methods (instance-based for provider)
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await dio.get(endpoint);
      return response.data is Map ? response.data : {};
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'GET request failed');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(endpoint, data: data);
      return response.data is Map ? response.data : {};
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'POST request failed');
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(endpoint, data: data);
      return response.data is Map ? response.data : {};
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'PUT request failed');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await dio.delete(endpoint);
      return response.data is Map ? response.data : {};
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'DELETE request failed');
    }
  }
}
