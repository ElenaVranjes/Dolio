import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuth = false;
  bool _isAdmin = false;

  String _email = '';
  String _fullName = '';
  String _address = '';
  String _phone = '';

  bool get isAuth => _isAuth;
  bool get isAdmin => _isAdmin;

  String get email => _email;
  String get fullName => _fullName;
  String get address => _address;
  String get phone => _phone;

  String get displayName {
    if (_fullName.isNotEmpty) return _fullName;
    if (_email.isNotEmpty) {
      return _email.split('@').first;
    }
    return 'korisnik';
  }

  Future<void> login(
    String email,
    String password, {
    bool asAdmin = false,
  }) async {
    _isAuth = true;
    _isAdmin = asAdmin;
    _email = email;
    notifyListeners();
  }

  void logout() {
    _isAuth = false;
    _isAdmin = false;
    _email = '';
    _fullName = '';
    _address = '';
    _phone = '';
    notifyListeners();
  }

  void updateProfile({
    String? fullName,
    String? address,
    String? phone,
  }) {
    if (fullName != null) _fullName = fullName;
    if (address != null) _address = address;
    if (phone != null) _phone = phone;
    notifyListeners();
  }
}
