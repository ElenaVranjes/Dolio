import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/product_grid_item.dart';

class ProductsOverviewScreen extends StatefulWidget {
  final String? initialCategory;

  const ProductsOverviewScreen({super.key, this.initialCategory});

  @override
  State<ProductsOverviewScreen> createState() =>
      _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState
    extends State<ProductsOverviewScreen> {
  late String _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Sve';
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: true);

    final allCategories = ['Sve', ...productsProvider.categories];

    var products = _selectedCategory == 'Sve'
        ? productsProvider.items
        : productsProvider.byCategory(_selectedCategory);

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      products = products
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Pretraži proizvode...',
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: allCategories.length,
            itemBuilder: (ctx, i) {
              final cat = allCategories[i];
              final isSelected = _selectedCategory == cat;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => _selectCategory(cat),
                  selectedColor: colorScheme.primary,
                  backgroundColor: Theme.of(context).cardColor,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.grey.shade300,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (ctx, i) {
                final product = products[i];
                return ProductGridItem(product: product);
              },
            ),
          ),
        ),
      ],
    );
  }
}
