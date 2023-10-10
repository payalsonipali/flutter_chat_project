import 'package:flutter/material.dart';

class PasswordProvider with ChangeNotifier {
  bool _isPasswordObscured = true;

  bool get isPasswordObscured => _isPasswordObscured;

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }
}