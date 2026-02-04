import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roomix/services/api_service.dart';
import 'package:roomix/utils/storage_util.dart';
import 'package:roomix/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final StorageUtil _storageUtil = StorageUtil();
  FirebaseAuth? _firebaseAuth;
  GoogleSignIn? _googleSignIn;
  
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  
  // Get Firebase current user
  User? get firebaseUser => _firebaseAuth?.currentUser;

  AuthProvider() {
    _initializeFirebaseIfAvailable();
    _initializeAuth();
  }

  void _initializeFirebaseIfAvailable() {
    if (Firebase.apps.isNotEmpty) {
      _firebaseAuth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn();
    }
  }

  void _ensureFirebaseReady() {
    if (_firebaseAuth == null || _googleSignIn == null) {
      _initializeFirebaseIfAvailable();
    }
    if (_firebaseAuth == null || _googleSignIn == null) {
      throw Exception('Firebase is not initialized');
    }
  }

  Future<void> _initializeAuth() async {
    try {
      final token = await _storageUtil.getToken();
      final user = await _storageUtil.getUser();
      
      if (token != null && user != null) {
        _currentUser = UserModel.fromJson(user);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    }
  }

  // Standard email/password login (for regular users)
  Future<Map<String, dynamic>> login(String email, String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.login(email, password, role);
      
      if (result.containsKey('requiresOtp') && result['requiresOtp'] == true) {
        _isLoading = false;
        notifyListeners();
        return {'requiresOtp': true, 'email': result['email']};
      }

      // Login successful
      await _storageUtil.saveToken(result['token']);
      final user = UserModel.fromJson(result);
      await _storageUtil.saveUser(result);
      
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      
      return {'success': true};
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  // Firebase Google Sign-In
  Future<Map<String, dynamic>> signInWithGoogle(String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Sign out first to ensure fresh sign-in
      _ensureFirebaseReady();
      await _googleSignIn!.signOut();
      
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      
      if (googleUser == null) {
        _isLoading = false;
        _errorMessage = 'Google Sign-In was cancelled';
        notifyListeners();
        return {'cancelled': true};
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await _firebaseAuth!.signInWithCredential(credential);

      // Get the Firebase ID token for backend verification
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Send the Firebase ID token to backend for authentication
      final result = await ApiService.googleAuth(
        idToken: idToken,
        email: googleUser.email,
        name: googleUser.displayName ?? 'User',
        photoUrl: googleUser.photoUrl,
        role: role,
      );

      // Save user data locally
      await _storageUtil.saveToken(result['token']);
      final user = UserModel.fromJson(result);
      await _storageUtil.saveUser(result);
      
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      
      // Check for specific error messages
      if (errorMsg.contains('email does not exist') || 
          errorMsg.contains('User not found')) {
        _errorMessage = 'This email is not registered. Please use another email or sign up first.';
      } else {
        _errorMessage = errorMsg;
      }
      
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  // Get Firebase error message
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different credential';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      case 'operation-not-allowed':
        return 'Google Sign-In is not enabled';
      case 'user-disabled':
        return 'This user has been disabled';
      case 'user-not-found':
        return 'This email is not registered. Please use another email.';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.verifyOtp(email, otp);
      
      await _storageUtil.saveToken(result['token']);
      final user = UserModel.fromJson(result);
      await _storageUtil.saveUser(result);
      
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  Future<void> register(String name, String email, String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.register(name, email, password, role);
      
      await _storageUtil.saveToken(result['token']);
      final user = UserModel.fromJson(result);
      await _storageUtil.saveUser(result);
      
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  // Password Recovery: Send OTP to email
  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  // Password Recovery: Verify OTP
  Future<String> verifyResetOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.verifyResetOtp(email, otp);
      _isLoading = false;
      notifyListeners();
      
      // Return the reset token for use in password reset
      return result['resetToken'] ?? '';
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  // Password Recovery: Reset Password with Token
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.resetPassword(
        email: email,
        resetToken: resetToken,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  // Profile: fetch current profile
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.getProfile();
      // merge into current user
      final user = UserModel.fromJson(result);
      _currentUser = user;
      await _storageUtil.saveUser(result);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.updateProfile(updates);
      if (result.containsKey('user')) {
        final user = UserModel.fromJson(result['user']);
        _currentUser = user;
        await _storageUtil.saveUser(result['user']);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.updateSettings(settings);
      // update local user settings
      if (_currentUser != null && result.containsKey('notificationSettings')) {
        final merged = {
          'notificationSettings': result['notificationSettings'],
          'privacySettings': result['privacySettings'],
        };
        final mergedUser = _currentUser!.toJson()..addAll(merged);
        _currentUser = UserModel.fromJson(mergedUser);
        await _storageUtil.saveUser(mergedUser);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  Future<void> uploadProfilePicture(String filePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.uploadProfilePicture(filePath);
      if (result.containsKey('profilePicture')) {
        final updated = _currentUser?.toJson() ?? {};
        updated['_id'] = _currentUser?.id;
        updated['profilePicture'] = result['profilePicture'];
        _currentUser = UserModel.fromJson(updated);
        await _storageUtil.saveUser(updated);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Sign out from Firebase
      if (_firebaseAuth != null) {
        await _firebaseAuth!.signOut();
      }
      // Sign out from Google
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
      // Clear local storage
      await _storageUtil.clearAll();
      
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
