import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AuthService {
  /// Register a new user
  Future<ParseUser?> register(String email, String password) async {
    final user = ParseUser(email, password, email);
    final response = await user.signUp();
    if (response.success && response.result != null) {
      return response.result as ParseUser;
    }
    throw Exception(response.error?.message ?? 'Registration failed');
  }

  /// Login User
  Future<ParseUser?> login(String email, String password) async {
    final user = ParseUser(email, password, email);
    final response = await user.login();
    if (response.success && response.result != null) {
      return response.result as ParseUser;
    }
    throw Exception(response.error?.message ?? 'Login failed');
  }

  /// Logout current user
  Future<void> logout() async {
    final current = await ParseUser.currentUser() as ParseUser?;
    if (current != null) {
      final response = await current.logout();
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Logout failed');
      }
    }
  }

  /// Get current logged-in user
  Future<ParseUser?> currentUser() async {
    return await ParseUser.currentUser() as ParseUser?;
  }
}
