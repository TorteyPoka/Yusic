import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String _userKey = 'current_user';

  // Sample credentials for demo
  // Artist: username: artist, password: artist11
  // Studio: username: studio, password: studio11

  Future<UserModel> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    UserModel? user;

    // Check artist credentials
    if (username == 'artist' && password == 'artist11') {
      user = UserModel(
        id: 'artist_001',
        email: 'artist@yusic.com',
        name: 'John Artist',
        userType: UserType.artist,
        bio: 'Passionate musician and producer',
        privateFolderCount: 3,
        privateFolderLimit: 10,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLogin: DateTime.now(),
      );
    }
    // Check studio credentials
    else if (username == 'studio' && password == 'studio11') {
      user = UserModel(
        id: 'studio_001',
        email: 'studio@yusic.com',
        name: 'Sound Wave Studio',
        userType: UserType.studio,
        bio: 'Professional recording and jamming studio in Dhaka',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        lastLogin: DateTime.now(),
      );
    } else {
      throw Exception('Invalid credentials');
    }

    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));

    return user;
  }

  Future<UserModel> register(
      String name, String email, String password, UserType userType) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      userType: userType,
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));

    return user;
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
