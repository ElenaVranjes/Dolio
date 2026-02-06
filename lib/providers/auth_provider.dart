import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _firebaseUser;
  bool _isAdmin = false;
  String _fullName = '';
  String _address = '';
  String _phone = '';

  AuthProvider() {
    // svaki put kad se promeni auth stanje, učitamo profil
    _auth.authStateChanges().listen(_onAuthChanged);
  }

  bool get isAuth => _firebaseUser != null;
  bool get isAdmin => _isAdmin;

  String get uid => _firebaseUser?.uid ?? '';
  String get email => _firebaseUser?.email ?? '';

  String get displayName {
    if (_fullName.isNotEmpty) return _fullName;
    if (email.isNotEmpty) return email;
    return 'Korisnik';
  }

  String get fullName => _fullName;
  String get address => _address;
  String get phone => _phone;

  Future<void> _onAuthChanged(User? user) async {
    _firebaseUser = user;

    if (user == null) {
      _isAdmin = false;
      _fullName = '';
      _address = '';
      _phone = '';
      notifyListeners();
      return;
    }

    try {
      final doc = await _db.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        _fullName = (data['fullName'] ?? '') as String;
        _address = (data['address'] ?? '') as String;
        _phone = (data['phone'] ?? '') as String;
        _isAdmin = (data['isAdmin'] ?? false) as bool;
      } else {
        // ako profil ne postoji, kreiramo osnovni
        _fullName = user.email ?? '';
        _address = '';
        _phone = '';
        _isAdmin = false;

        await _db.collection('users').doc(user.uid).set({
          'email': user.email,
          'fullName': _fullName,
          'address': _address,
          'phone': _phone,
          'isAdmin': _isAdmin,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Greška pri čitanju profila korisnika: $e');
      }
    }

    notifyListeners();
  }

  /// Registracija novog korisnika (email + lozinka + ime)
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    _firebaseUser = cred.user;

    _fullName = fullName;
    _address = '';
    _phone = '';
    _isAdmin = false;

    await _db.collection('users').doc(cred.user!.uid).set({
      'email': email,
      'fullName': fullName,
      'address': '',
      'phone': '',
      'isAdmin': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    notifyListeners();
  }

  /// Prijava postojećeg korisnika
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    _firebaseUser = cred.user;
    await _onAuthChanged(_firebaseUser);
  }

  /// Odjava korisnika
  Future<void> logout() async {
    await _auth.signOut();
    _firebaseUser = null;
    _isAdmin = false;
    _fullName = '';
    _address = '';
    _phone = '';
    notifyListeners();
  }

  /// Ažuriranje profila (ime, adresa, telefon)
  Future<void> updateProfile({
    required String fullName,
    required String address,
    required String phone,
  }) async {
    if (_firebaseUser == null) return;

    _fullName = fullName;
    _address = address;
    _phone = phone;

    await _db.collection('users').doc(_firebaseUser!.uid).update({
      'fullName': fullName,
      'address': address,
      'phone': phone,
    });

    notifyListeners();
  }
}
