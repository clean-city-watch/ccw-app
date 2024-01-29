import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  bool _isUserLoggedIn = false;
  bool _isOrgManagerLoggedIn = false;

  bool get isUserLoggedIn => _isUserLoggedIn;
  bool get isOrgManagerLoggedIn => _isOrgManagerLoggedIn;

  void setLoggedInStatus(bool userLoginValue, bool orgManagerLoginValue) {
    _isUserLoggedIn = userLoginValue;
    _isOrgManagerLoggedIn = orgManagerLoginValue;
    notifyListeners();
  }
}
