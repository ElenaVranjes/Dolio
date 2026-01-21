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
}
