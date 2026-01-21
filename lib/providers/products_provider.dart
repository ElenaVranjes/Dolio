import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/assets_manager.dart';

class ProductsProvider with ChangeNotifier {
  final List<Product> _items = [
    Product(
      id: 'p1',
      name: 'Takmičarski kimono',
      description: 'Lagan WTF approved kimono za takmičare.',
      category: 'Odeća',
      price: 8500,
      imageUrl: AssetsManager.prodCompetitionKimono,
      sizes: ['150', '160', '170', '180'],
      colors: ['Bela', 'Plava'],
      isPopular: true,
    ),
    Product(
      id: 'p2',
      name: 'Crni pojas',
      description: 'Crni pojas, višeslojni, vrhunskog kvaliteta.',
      category: 'Oprema',
      price: 3200,
      imageUrl:  AssetsManager.prodBlackBelt,
      sizes: ['260', '280', '300'],
      colors: ['Crna'],
      isPopular: true,
    ),
    Product(
      id: 'p3',
      name: 'Štitnik za potkolenicu',
      description: 'Elastični štitnik za potkolenicu sa ojačanjima.',
      category: 'Štitnici',
      price: 2900,
      imageUrl: AssetsManager.catStitnici,
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Bela', 'Crna'],
      isPopular: false,
    ),
    Product(
      id: 'p4',
      name: 'Fokuser',
      description: 'Dvostruki fokuser za vežbanje preciznosti i snage.',
      category: 'Dodaci',
      price: 4500,
      imageUrl: AssetsManager.prodDroppelHandMitt,
      sizes: ['Uni'],
      colors: ['Crvena', 'Plava'],
      isPopular: true,
    ),
  ];

  List<Product> get items => List.unmodifiable(_items);

  List<String> get categories {
    return _items.map((p) => p.category).toSet().toList();
  }

  List<Product> byCategory(String? category) {
    if (category == null || category == 'Sve') {
      return items;
    }
    return _items.where((p) => p.category == category).toList();
  }

  List<Product> search(String query, String? category) {
    final base = byCategory(category);
    if (query.trim().isEmpty) return base;
    final lower = query.toLowerCase();
    return base
        .where((p) => p.name.toLowerCase().contains(lower))
        .toList();
  }

  List<Product> get favorites =>
      _items.where((p) => p.isFavorite).toList();

  List<Product> get popular =>
      _items.where((p) => p.isPopular).toList();

  Product findById(String id) {
    return _items.firstWhere((p) => p.id == id);
  }

  void toggleFavoriteStatus(String id) {
    final index = _items.indexWhere((p) => p.id == id);
    if (index == -1) return;
    _items[index].isFavorite = !_items[index].isFavorite;
    notifyListeners();
  }

  void addProduct(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void updateProduct(String id, Product newProduct) {
    final index = _items.indexWhere((p) => p.id == id);
    if (index >= 0) {
      _items[index] = newProduct;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _items.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void clearFavorites() {
    for (final product in _items) {
      product.isFavorite = false;
    }
    notifyListeners();
  }
}
