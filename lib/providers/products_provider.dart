import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<Product> _items = [];
  bool _isLoading = false;

  ProductsProvider() {
    // čim se Provider kreira, povuci proizvode iz baze
    _loadProductsFromFirestore();
  }

  bool get isLoading => _isLoading;

  List<Product> get items => List.unmodifiable(_items);

  List<Product> get popular =>
      _items.where((p) => p.isPopular).toList(growable: false);

  List<Product> get favorites =>
      _items.where((p) => p.isFavorite).toList(growable: false);

  List<String> get categories =>
      _items.map((p) => p.category).toSet().toList(growable: false);

  /// Učitavanje svih proizvoda iz Firestore-a
  Future<void> _loadProductsFromFirestore() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snap = await _db.collection('products').get();

      _items
        ..clear()
        ..addAll(
          snap.docs.map(
            (doc) => Product.fromFirestore(doc),
          ),
        );
    } catch (e) {
      if (kDebugMode) {
        print('Greška pri učitavanju proizvoda: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ručno osvežavanje (ako ti zatreba npr. pull-to-refresh)
  Future<void> refresh() => _loadProductsFromFirestore();

  Product findById(String id) {
    return _items.firstWhere((p) => p.id == id);
  }

  List<Product> byCategory(String? category) {
    if (category == null || category == 'Sve') {
      return List.unmodifiable(_items);
    }
    return _items
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList(growable: false);
  }

  List<Product> search(String query, String? category) {
    final base = byCategory(category);
    if (query.trim().isEmpty) return base;

    final lower = query.toLowerCase();
    return base
        .where((p) => p.name.toLowerCase().contains(lower))
        .toList(growable: false);
  }

  /// Omiljeni – za sada ostaje lokalno u Provideru (frontend),
  /// ako bude trebalo, možemo ih vezati za Firestore / korisnika.
  void toggleFavoriteStatus(String id) {
    final index = _items.indexWhere((p) => p.id == id);
    if (index == -1) return;

    _items[index].isFavorite = !_items[index].isFavorite;
    notifyListeners();
  }

  void clearFavorites() {
    for (final p in _items) {
      p.isFavorite = false;
    }
    notifyListeners();
  }

  /// ====== ADMIN CRUD – rade direktno nad Firestore-om ======

  Future<void> addProduct(Product product) async {
    try {
      final docRef =
          await _db.collection('products').add(product.toMap());

      final created = product.copyWith(id: docRef.id);
      _items.add(created);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Greška pri dodavanju proizvoda: $e');
      }
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final index = _items.indexWhere((p) => p.id == id);
    if (index == -1) return;

    try {
      await _db
          .collection('products')
          .doc(id)
          .update(newProduct.toMap());

      // zadržavamo info da li je bio omiljeni
      final wasFavorite = _items[index].isFavorite;
      _items[index] = newProduct.copyWith(
        id: id,
        isFavorite: wasFavorite,
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Greška pri izmeni proizvoda: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    final index = _items.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final backup = _items[index];
    _items.removeAt(index);
    notifyListeners();

    try {
      await _db.collection('products').doc(id).delete();
    } catch (e) {
      // ako ne uspe brisanje u bazi, vrati u listu
      _items.insert(index, backup);
      notifyListeners();

      if (kDebugMode) {
        print('Greška pri brisanju proizvoda: $e');
      }
      rethrow;
    }
  }
}
