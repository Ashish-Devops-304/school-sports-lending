import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class UserProvider with ChangeNotifier {
  ParseUser? _user;

  ParseUser? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> loadCurrentUser() async {
    try {
      ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;

      if (currentUser != null) {

        // --- THIS IS THE FIX ---
        // 'fetch()' returns a generic ParseObject,
        // so we must cast it back to a ParseUser.
        final ParseObject fetchedObject = await currentUser.fetch();
        _user = fetchedObject as ParseUser; 
        // --- END FIX ---

      } else {
        _user = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading current user: $e");
      }
      _user = null;
    }
    notifyListeners();
  }

  void setUser(ParseUser user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      if (_user != null) {
        await _user!.logout();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error during logout: $e");
      }
    } finally {
      _user = null;
      notifyListeners();
    }
  }
}