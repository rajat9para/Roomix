import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:roomix/models/roommate_profile_model.dart';
import 'package:roomix/models/chat_message_model.dart';
import 'package:roomix/services/api_service.dart';

class RoommateProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Profile state
  RoommateProfile? _myProfile;
  List<RoommateProfile> _allProfiles = [];
  List<RoommateProfile> _matches = [];
  bool _profileComplete = false;
  bool _isLoading = false;
  String? _error;

  // Chat state
  List<ChatMessage> _messages = [];
  List<ChatConversation> _conversations = [];
  String? _selectedConversationId;
  Timer? _pollTimer;

  // Getters
  RoommateProfile? get myProfile => _myProfile;
  List<RoommateProfile> get allProfiles => _allProfiles;
  List<RoommateProfile> get matches => _matches;
  bool get profileComplete => _profileComplete;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ChatMessage> get messages => _messages;
  List<ChatConversation> get conversations => _conversations;
  String? get selectedConversationId => _selectedConversationId;

  // Create or update profile
  Future<void> createProfile(
    String bio,
    List<String> interests,
    Map<String, dynamic> preferences,
    {String? gender, String? courseYear, String? college}
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.post(
        '/roommates/profile',
        {
          'bio': bio,
          'interests': interests,
          'preferences': preferences,
          'gender': gender,
          'courseYear': courseYear,
          'college': college,
        },
      );

      if (response.containsKey('profile')) {
        _myProfile = RoommateProfile.fromJson(response['profile']);
        _profileComplete = true;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get my profile
  Future<void> getMyProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/roommates/profile');

      if (response.containsKey('profile')) {
        _myProfile = RoommateProfile.fromJson(response['profile']);
        _profileComplete = _myProfile?.profileComplete ?? false;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get all profiles
  Future<void> getAllProfiles() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/roommates/all');

      if (response.containsKey('profiles')) {
        final profilesJson = response['profiles'] as List;
        _allProfiles = profilesJson.map((p) => RoommateProfile.fromJson(p)).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get compatible matches
  Future<void> getMatches() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/roommates/matches');

      if (response.containsKey('matches')) {
        final matchesJson = response['matches'] as List;
        _matches = matchesJson.map((m) => RoommateProfile.fromJson(m)).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send message
  Future<void> sendMessage(String receiverId, String message) async {
    try {
      _error = null;
      final response = await _apiService.post(
        '/chat/send',
        {
          'receiver': receiverId,
          'message': message,
        },
      );

      if (response.containsKey('data')) {
        final newMessage = ChatMessage.fromJson(response['data']);
        _messages.add(newMessage);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get messages with a user
  Future<void> getMessages(String conversationId) async {
    try {
      _selectedConversationId = conversationId;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/chat/messages/$conversationId');

      if (response.containsKey('messages')) {
        final messagesJson = response['messages'] as List;
        _messages = messagesJson.map((m) => ChatMessage.fromJson(m)).toList();
      }

      // Mark messages as read
      await markAsRead(conversationId);
      startPolling(conversationId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get all conversations
  Future<void> getConversations() async {
    try {
      _error = null;
      final response = await _apiService.get('/chat/conversations');

      if (response.containsKey('conversations')) {
        final conversationsJson = response['conversations'] as List;
        _conversations = conversationsJson.map((c) => ChatConversation.fromJson(c)).toList();
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String conversationId) async {
    try {
      await _apiService.put(
        '/chat/read/$conversationId',
        {},
      );
    } catch (e) {
      _error = e.toString();
    }
  }

  // Start polling for new messages (3 seconds)
  void startPolling(String conversationId) {
    stopPolling();

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final response = await _apiService.get('/chat/messages/$conversationId');

        if (response.containsKey('messages')) {
          final messagesJson = response['messages'] as List;
          final newMessages = messagesJson.map((m) => ChatMessage.fromJson(m)).toList();

          // Check if there are new messages
          if (newMessages.length != _messages.length) {
            _messages = newMessages;
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint('Polling error: $e');
      }
    });
  }

  // Stop polling
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      _error = null;
      await _apiService.delete('/chat/message/$messageId');

      _messages.removeWhere((m) => m.id == messageId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete profile
  Future<void> deleteProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.delete('/roommates/profile');

      _myProfile = null;
      _profileComplete = false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Clear state
  void clearState() {
    stopPolling();
    _selectedConversationId = null;
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
