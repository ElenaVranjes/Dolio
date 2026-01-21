import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  final String id; // id zapisa u korpi
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String? size;
  final String? color;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.size,
    this.color,
  });

  CartItem copyWith({
    int? quantity,
  }) {
    return CartItem(
      id: id,
      productId: productId,
      name: name,
      quantity: quantity ?? this.quantity,
      price: price,
      size: size,
      color: color,
    );
  }
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => Map.unmodifiable(_items);

  int get itemCount {
    int total = 0;
    for (final item in _items.values) {
      total += item.quantity;
    }
    return total;
  }

  double get totalAmount {
    double total = 0;
    for (final item in _items.values) {
      total += item.price * item.quantity;
    }
    return total;
  }

  void addItem(
    Product product, {
    String? size,
    String? color,
  }) {
    final key = '${product.id}_${size ?? ''}_${color ?? ''}';

    if (_items.containsKey(key)) {
      final existing = _items[key]!;
      _items[key] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
    } else {
      _items[key] = CartItem(
        id: key,
        productId: product.id,
        name: product.name,
        quantity: 1,
        price: product.price,
        size: size,
        color: color,
      );
    }
    notifyListeners();
  }

  void removeItem(String cartItemId) {
    _items.remove(cartItemId);
    notifyListeners();
  }

  void increaseQuantity(String cartItemId) {
    final existing = _items[cartItemId];
    if (existing == null) return;
    _items[cartItemId] = existing.copyWith(
      quantity: existing.quantity + 1,
    );
    notifyListeners();
  }

  void decreaseQuantity(String cartItemId) {
    final existing = _items[cartItemId];
    if (existing == null) return;
    if (existing.quantity <= 1) {
      _items.remove(cartItemId);
    } else {
      _items[cartItemId] = existing.copyWith(
        quantity: existing.quantity - 1,
      );
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
