import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void signup(String username, String password) {
    // Call API to signup user
    // On success:
    _isLoggedIn = true;
    notifyListeners();
  }

  void login(String username, String password) {
    // Call API to login user
    // On success:
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
