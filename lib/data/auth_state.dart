import 'package:flutter/foundation.dart';

class AuthState extends ChangeNotifier {
  bool isLoggedIn = false;
  String adminName = 'Admin';


  bool twoFactorPassed = false;

  void login(String email) {
    isLoggedIn = true;
    twoFactorPassed = false;
    adminName = email.isNotEmpty ? email.split('@').first : 'Admin';
    notifyListeners();
  }

  void passTwoFactor() {
    twoFactorPassed = true;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    twoFactorPassed = false;
    notifyListeners();
  }
}

final authState = AuthState();
