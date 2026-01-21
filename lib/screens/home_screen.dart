import 'package:dolio/services/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/product_grid_item.dart';

class HomeScreen extends StatelessWidget {
  final void Function(String category)? onCategorySelected;

  const HomeScreen({super.key, this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final newProducts = productsProvider.popular;

    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HERO
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  AssetsManager.homeHero,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.black.withOpacity(0.15),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                            children: [
                              const TextSpan(
                                text: 'TEKVONDO ',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: 'OPREMA',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sve za vaš trening i takmičenje!',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          //kategorije
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _CategoryRow(
                  leftTitle: 'ŠTITNICI',
                  leftImage: AssetsManager.catStitnici,
                  leftTargetCategory: 'Štitnici',   
                  rightTitle: 'ODEĆA',
                  rightImage: AssetsManager.catOdeca,
                  rightTargetCategory: 'Odeća',    
                  onCategorySelected: onCategorySelected,
                ),
                const SizedBox(height: 12),
                _CategoryRow(
                  leftTitle: 'OPREMA',
                  leftImage: AssetsManager.catOprema,
                  leftTargetCategory: 'Oprema',   
                  rightTitle: 'DODACI',
                  rightImage: AssetsManager.catDodaci,
                  rightTargetCategory: 'Dodaci', 
                  onCategorySelected: onCategorySelected,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOVI PROIZVODI',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Najnovija oprema',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: newProducts.length,
              itemBuilder: (ctx, i) {
                final p = newProducts[i];
                return SizedBox(
                  width: 220,
                  child: ProductGridItem(product: p),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          //footer
          Container(
            width: double.infinity,
            color: colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'O shopu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'DolioApp je specijalizovana mobilna prodavnica tekvondo opreme – '
                  'kimona, pojaseva, zaštitne opreme i rekvizita za trening.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Kontakt',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Email: info@dolioapp.com',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                Text(
                  'Telefon: +381 64 123 4567',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Informacije',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Radno vreme: Pon–Pet 09–17h',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                Text(
                  'Isporuka na teritoriji Srbije.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String leftTitle;
  final String leftImage;
  final String leftTargetCategory;
  final String rightTitle;
  final String rightImage;
  final String rightTargetCategory;
  final void Function(String category)? onCategorySelected;

  const _CategoryRow({
    required this.leftTitle,
    required this.leftImage,
    required this.leftTargetCategory,
    required this.rightTitle,
    required this.rightImage,
    required this.rightTargetCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CategoryCard(
            title: leftTitle,
            imagePath: leftImage,
            targetCategory: leftTargetCategory,
            onCategorySelected: onCategorySelected,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CategoryCard(
            title: rightTitle,
            imagePath: rightImage,
            targetCategory: rightTargetCategory,
            onCategorySelected: onCategorySelected,
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String targetCategory;
  final void Function(String category)? onCategorySelected;

  const _CategoryCard({
    required this.title,
    required this.imagePath,
    required this.targetCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onCategorySelected != null) {
          onCategorySelected!(targetCategory);
        }
      },
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
