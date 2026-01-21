import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';

  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  String? _selectedColor;
  bool _initialized = false;

  void _addToCart(
    BuildContext context,
    String productId,
  ) {
    final auth =
        Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Za dodavanje u korpu potrebno je da se prijavite.'),
        ),
      );
      Navigator.of(context).pushNamed(AuthScreen.routeName);
      return;
    }

    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    final cart =
        Provider.of<CartProvider>(context, listen: false);
    final product = productsProvider.findById(productId);

    cart.addItem(
      product,
      size: _selectedSize,
      color: _selectedColor,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proizvod dodat u korpu.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productId =
        ModalRoute.of(context)!.settings.arguments as String;
    final product =
        Provider.of<ProductsProvider>(context).findById(productId);

    if (!_initialized) {
      _selectedSize =
          product.sizes.isNotEmpty ? product.sizes.first : null;
      _selectedColor =
          product.colors.isNotEmpty ? product.colors.first : null;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.asset(
                product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style:
                        Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.price.toStringAsFixed(0)} RSD',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(product.description),
                  const SizedBox(height: 16),
                  if (product.sizes.isNotEmpty) ...[
                    Text(
                      'Veličina',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: product.sizes.map((size) {
                        final selected = size == _selectedSize;
                        return ChoiceChip(
                          label: Text(size),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedSize = size;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (product.colors.isNotEmpty) ...[
                    Text(
                      'Boja',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: product.colors.map((color) {
                        final selected = color == _selectedColor;
                        return ChoiceChip(
                          label: Text(color),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _addToCart(context, productId),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Dodaj u korpu'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
