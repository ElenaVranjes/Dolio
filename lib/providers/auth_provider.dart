import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _firebaseUser;

  bool _isLoading = false;
  bool _isAdmin = false;

  String _fullName = '';
  String _address = '';
  String _phone = '';

  AuthProvider() {
    // Svaki put kad se korisnik uloguje / izloguje, ovde dobijamo event
    _auth.authStateChanges().listen(_onAuthChanged);
  }

  // GETTERI
  bool get isLoading => _isLoading;
  bool get isAuth => _firebaseUser != null;
  String get userId => _firebaseUser?.uid ?? '';
  String get email => _firebaseUser?.email ?? '';

  /// Tekst za pozdrav – ime iz profila ako postoji,
  /// inače deo mejla pre @
  String get displayName {
    if (_fullName.isNotEmpty) return _fullName;
    final mail = _firebaseUser?.email;
    if (mail == null) return '';
    return mail.split('@').first;
  }

  String get fullName => _fullName;
  String get address => _address;
  String get phone => _phone;
  bool get isAdmin => _isAdmin;

  // LISTENER na promenu ulogovanog user-a
  Future<void> _onAuthChanged(User? user) async {
    _firebaseUser = user;
    if (user == null) {
      _fullName = '';
      _address = '';
      _phone = '';
      _isAdmin = false;
      notifyListeners();
      return;
    }

    await _loadUserProfile(user.uid);
    notifyListeners();
  }

  // Učitavanje profila iz Firestore-a (po UID-u!)
  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists) {
        // Ako još nema dokumenta, napravi prazan
        await _db.collection('users').doc(uid).set({
          'email': _firebaseUser?.email,
          'fullName': '',
          'address': '',
          'phone': '',
          'isAdmin': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _fullName = '';
        _address = '';
        _phone = '';
        _isAdmin = false;
        return;
      }

      final data = doc.data()!;
      _fullName = (data['fullName'] ?? '') as String;
      _address = (data['address'] ?? '') as String;
      _phone = (data['phone'] ?? '') as String;

      // podržava ili isAdmin: true ili role: 'admin'
      final role = data['role'];
      final bool isAdminField = data['isAdmin'] == true;
      _isAdmin = isAdminField || role == 'admin';
    } catch (e) {
      if (kDebugMode) {
        print('Greška pri učitavanju profila: $e');
      }
    }
  }

  // REGISTRACIJA
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = cred.user;

      await _db.collection('users').doc(cred.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'address': '',
        'phone': '',
        'isAdmin': false, // admina ručno podesiš u konzoli
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _loadUserProfile(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // AuthScreen već hvata poruku
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // PRIJAVA
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = cred.user;
      await _loadUserProfile(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ODJAVA
  Future<void> logout() async {
    await _auth.signOut();
    // _authStateChanges listener će sve resetovati
  }

  // AŽURIRANJE PROFILA
  Future<void> updateProfile({
    required String fullName,
    required String address,
    required String phone,
  }) async {
    if (_firebaseUser == null) return;

    _fullName = fullName;
    _address = address;
    _phone = phone;

    try {
      await _db.collection('users').doc(_firebaseUser!.uid).update({
        'fullName': fullName,
        'address': address,
        'phone': phone,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Greška pri ažuriranju profila: $e');
      }
    }

    notifyListeners();
  }
}
