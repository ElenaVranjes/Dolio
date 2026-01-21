import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../screens/product_detail_screen.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;

  const ProductGridItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context);
    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black.withOpacity(0.5),
          title: Text(
            product.name,
            style: const TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            '${product.price.toStringAsFixed(0)} RSD',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (auth.isAuth)
                IconButton(
                  icon: Icon(
                    product.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    productsProvider
                        .toggleFavoriteStatus(product.id);
                  },
                ),

              IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                onPressed: () {
                  cart.addItem(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} dodat u korpu'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
