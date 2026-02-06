import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final List<String> sizes;
  final List<String> colors;
  final bool isPopular;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.sizes,
    required this.colors,
    this.isPopular = false,
    this.isFavorite = false,
  });

  /// Kreiranje iz Firestore dokumenta
  factory Product.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return Product(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      imageUrl: data['imageUrl'] as String? ?? '',
      sizes: List<String>.from(data['sizes'] ?? const []),
      colors: List<String>.from(data['colors'] ?? const []),
      isPopular: data['isPopular'] as bool? ?? false,
      // isFavorite ne čuvamo u Firestore-u, već per-user / lokalno
      isFavorite: false,
    );
  }

  /// Map za upis u Firestore (ADD/UPDATE)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'sizes': sizes,
      'colors': colors,
      'isPopular': isPopular,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? imageUrl,
    List<String>? sizes,
    List<String>? colors,
    bool? isPopular,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      isPopular: isPopular ?? this.isPopular,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
