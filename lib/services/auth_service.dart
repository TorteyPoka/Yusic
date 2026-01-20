import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';
import 'dart:convert';

class AuthService {
  static const String _userKey = 'current_user';
  final SupabaseService _supabase = SupabaseService();

  // Login with Supabase Authentication
  Future<UserModel> login(String email, String password) async {
    try {
      // Sign in with Supabase Auth
      final response = await _supabase.signIn(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }

      // Get user profile from database
      final userProfile = await _supabase.getById('users', response.user!.id);

      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      final user = UserModel.fromJson({
        'id': response.user!.id,
        ...userProfile,
      });

      // Update last login
      await _supabase.update(
        'users',
        user.id,
        {'lastlogin': DateTime.now().toIso8601String()},
      );

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(user.toJson()));

      return user;
    } catch (e) {
      // Handle specific error types
      final errorMessage = e.toString();

      if (errorMessage.contains('Invalid login credentials')) {
        throw Exception('Invalid email or password. Please try again.');
      } else if (errorMessage.contains('Email not confirmed')) {
        throw Exception('Please verify your email before logging in.');
      } else if (errorMessage.contains('statusCode: 429')) {
        throw Exception(
            'Too many login attempts. Please wait a moment and try again.');
      } else {
        throw Exception('Login failed: $e');
      }
    }
  }

  // Register with Supabase Authentication
  Future<UserModel> register(
    String name,
    String email,
    String password,
    UserType userType, {
    String? bio,
  }) async {
    try {
      // Create Supabase Auth user
      final response = await _supabase.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'user_type': userType.toString().split('.').last,
        },
      );

      if (response.user == null) {
        throw Exception('Registration failed: No user returned');
      }

      // Check if email confirmation is required
      if (response.session == null) {
        throw Exception(
            'Registration successful! Please check your email to confirm your account before logging in.');
      }

      // Create user profile in database
      final userData = {
        'id': response.user!.id,
        'email': email,
        'name': name,
        'usertype': userType.toString().split('.').last,
        'bio': bio ?? '',
        'privatefoldercount': 0,
        'privatefolderlimit': userType == UserType.artist ? 10 : 0,
        'createdat': DateTime.now().toIso8601String(),
        'lastlogin': DateTime.now().toIso8601String(),
      };

      // Add delay to ensure auth user is fully created
      await Future.delayed(const Duration(milliseconds: 500));

      await _supabase.insert('users', userData);

      final user = UserModel(
        id: response.user!.id,
        email: email,
        name: name,
        userType: userType,
        bio: bio ?? '',
        privateFolderCount: 0,
        privateFolderLimit: userType == UserType.artist ? 10 : 0,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(user.toJson()));

      return user;
    } catch (e) {
      // Handle specific error types
      final errorMessage = e.toString();

      // Log the full error for debugging
      print('Registration error: $errorMessage');

      if (errorMessage.contains('PGRST204') ||
          errorMessage.contains('PGRST205') ||
          errorMessage.contains('Could not find the') &&
              errorMessage.contains('column') ||
          errorMessage.contains('Could not find the table') ||
          errorMessage.contains('relation') &&
              errorMessage.contains('does not exist') ||
          errorMessage.contains('schema cache')) {
        throw Exception(
            'Database schema mismatch. The error is: $errorMessage');
      } else if (errorMessage
              .contains('duplicate key value violates unique constraint') ||
          errorMessage.contains('already registered') ||
          errorMessage.contains('already exists')) {
        throw Exception(
            'This email is already registered. Try logging in instead.');
      } else if (errorMessage.contains('email_address_invalid') ||
          errorMessage.contains('Email address') &&
              errorMessage.contains('invalid')) {
        throw Exception('Invalid email address. Please check and try again.');
      } else if (errorMessage.contains('over_email_send_rate_limit')) {
        throw Exception(
            'Too many registration attempts. Please wait a minute and try again.');
      } else if (errorMessage.contains('Email rate limit exceeded')) {
        throw Exception(
            'Too many registration attempts. Please wait a minute and try again.');
      } else if (errorMessage.contains('violates foreign key constraint')) {
        throw Exception(
            'Registration error: User authentication succeeded but profile creation failed. Please try again.');
      } else if (errorMessage.contains('statusCode: 429')) {
        throw Exception(
            'Too many requests. Please wait a moment and try again.');
      } else if (errorMessage.contains('statusCode: 400')) {
        throw Exception('Invalid input. Please check your email and password.');
      } else if (errorMessage.contains('Password should be at least')) {
        throw Exception('Password should be at least 6 characters long.');
      } else {
        throw Exception('Registration failed: $errorMessage');
      }
    }
  }

  // Get current user from Supabase or local storage
  Future<UserModel?> getCurrentUser() async {
    try {
      final supabaseUser = _supabase.currentUser;

      if (supabaseUser == null) {
        // Try to get from local storage
        final prefs = await SharedPreferences.getInstance();
        final userJson = prefs.getString(_userKey);

        if (userJson != null) {
          return UserModel.fromJson(json.decode(userJson));
        }
        return null;
      }

      // Get user profile from database
      final userProfile = await _supabase.getById('users', supabaseUser.id);

      if (userProfile == null) {
        return null;
      }

      final user = UserModel.fromJson({
        'id': supabaseUser.id,
        ...userProfile,
      });

      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(user.toJson()));

      return user;
    } catch (e) {
      // Fallback to local storage if offline
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        return UserModel.fromJson(json.decode(userJson));
      }
      return null;
    }
  }

  // Stream user profile changes
  Stream<UserModel?> streamCurrentUser() {
    final userId = _supabase.currentUserId;
    if (userId == null) {
      return Stream.value(null);
    }

    return _supabase.streamWhere('users', 'id', userId).map((data) {
      if (data.isEmpty) {
        return null;
      }
      return UserModel.fromJson(data.first);
    });
  }

  // Logout
  Future<void> logout() async {
    await _supabase.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? bio,
    String? profileImageUrl,
  }) async {
    final userId = _supabase.currentUserId;
    if (userId == null) throw Exception('No user logged in');

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (bio != null) updates['bio'] = bio;
    if (profileImageUrl != null) updates['profileimage'] = profileImageUrl;

    if (updates.isNotEmpty) {
      await _supabase.update('users', userId, updates);

      // Update local storage
      final user = await getCurrentUser();
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, json.encode(user.toJson()));
      }
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.resetPassword(email);
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    await _supabase.updatePassword(newPassword);
  }

  // =======================
  // DEMO/TESTING METHODS
  // =======================

  Future<UserModel> demoLogin(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    UserModel? user;

    if (username == 'artist' && password == 'artist11') {
      user = UserModel(
        id: 'artist_demo_001',
        email: 'artist@demo.yusic.com',
        name: 'John Artist (Demo)',
        userType: UserType.artist,
        bio: 'Passionate musician and producer',
        privateFolderCount: 3,
        privateFolderLimit: 10,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLogin: DateTime.now(),
      );
    } else if (username == 'studio' && password == 'studio11') {
      user = UserModel(
        id: 'studio_demo_001',
        email: 'studio@demo.yusic.com',
        name: 'Sound Wave Studio (Demo)',
        userType: UserType.studio,
        bio: 'Professional recording studio',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        lastLogin: DateTime.now(),
      );
    } else {
      throw Exception('Invalid demo credentials');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));

    return user;
  }
}
