import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../models/product.dart';
import '../services/assets_manager.dart';
import 'admin_orders_screen.dart';
import 'admin_users_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  static const routeName = '/admin-panel';

  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  static const Map<String, String> _imageOptions = {
    'Takmičarski kimono': AssetsManager.prodCompetitionKimono,
    'Crni pojas': AssetsManager.prodBlackBelt,
    'Štitnik za potkolenicu': AssetsManager.catStitnici,
    'Fokuser': AssetsManager.prodDroppelHandMitt,
  };

  void _openProductForm(BuildContext context, {Product? existing}) {
    final isEdit = existing != null;

    final nameController =
        TextEditingController(text: existing?.name ?? '');
    final priceController = TextEditingController(
      text: existing != null
          ? existing.price.toStringAsFixed(0)
          : '',
    );
    final categoryController =
        TextEditingController(text: existing?.category ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');
    final sizesController = TextEditingController(
      text: existing != null ? existing.sizes.join(', ') : '',
    );
    final colorsController = TextEditingController(
      text: existing != null ? existing.colors.join(', ') : '',
    );

    String? selectedImageKey;
    if (existing != null) {
      _imageOptions.forEach((key, value) {
        if (value == existing.imageUrl) {
          selectedImageKey = key;
        }
      });
    }
    selectedImageKey ??= _imageOptions.keys.first;

    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (ctx) {
        final bottomInset =
            MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: bottomInset + 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius:
                          BorderRadius.circular(999),
                    ),
                  ),
                  Text(
                    isEdit
                        ? 'Izmena proizvoda'
                        : 'Novi proizvod',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Naziv proizvoda',
                    ),
                    validator: (val) {
                      if (val == null ||
                          val.trim().isEmpty) {
                        return 'Unesite naziv proizvoda';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Cena (RSD)',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    validator: (val) {
                      if (val == null ||
                          val.trim().isEmpty) {
                        return 'Unesite cenu';
                      }
                      final num? parsed =
                          num.tryParse(val);
                      if (parsed == null || parsed <= 0) {
                        return 'Unesite ispravnu cenu';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText:
                          'Kategorija (npr. Kimona, Oprema...)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Opis proizvoda',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: sizesController,
                    decoration: const InputDecoration(
                      labelText:
                          'Veličine (npr. 150, 160, 170)',
                      helperText: 'Odvojite zapetom',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: colorsController,
                    decoration: const InputDecoration(
                      labelText:
                          'Boje (npr. Crvena, Plava)',
                      helperText: 'Odvojite zapetom',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Slika proizvoda',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedImageKey,
                    dropdownColor: Colors.black,
                    decoration: const InputDecoration(
                      labelText: 'Odaberite sliku',
                    ),
                    items: _imageOptions.keys
                        .map(
                          (label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedImageKey = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!
                            .validate()) return;

                        final productsProvider =
                            Provider.of<ProductsProvider>(
                          context,
                          listen: false,
                        );

                        final imagePath =
                            _imageOptions[selectedImageKey] ??
                                (existing?.imageUrl ??
                                    AssetsManager
                                        .prodCompetitionKimono);

                        final sizes =
                            sizesController.text
                                .split(',')
                                .map((s) => s.trim())
                                .where((s) =>
                                    s.isNotEmpty)
                                .toList();
                        final colors =
                            colorsController.text
                                .split(',')
                                .map((s) => s.trim())
                                .where((s) =>
                                    s.isNotEmpty)
                                .toList();

                        final price = double.parse(
                          priceController.text
                              .replaceAll(',', '.'),
                        );

                        if (isEdit) {
                          final updated = Product(
                            id: existing.id,
                            name: nameController.text
                                .trim(),
                            description:
                                descriptionController.text
                                    .trim(),
                            category:
                                categoryController.text
                                    .trim(),
                            price: price,
                            imageUrl: imagePath,
                            sizes: sizes,
                            colors: colors,
                            isPopular:
                                existing.isPopular,
                            isFavorite:
                                existing.isFavorite,
                          );
                          productsProvider
                              .updateProduct(
                                  existing.id,
                                  updated);
                        } else {
                          final newProduct = Product(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            name: nameController.text
                                .trim(),
                            description:
                                descriptionController.text
                                    .trim(),
                            category:
                                categoryController.text
                                    .trim(),
                            price: price,
                            imageUrl: imagePath,
                            sizes: sizes,
                            colors: colors,
                            isPopular: false,
                            isFavorite: false,
                          );
                          productsProvider
                              .addProduct(
                                  newProduct);
                        }

                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        isEdit
                            ? 'Sačuvaj izmene'
                            : 'Dodaj proizvod',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider =
        Provider.of<ProductsProvider>(context);
    final products = productsProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administratorski panel'),
        actions: [
          IconButton(
            tooltip: 'Sve narudžbine',
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const AdminOrdersScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Registrovani korisnici',
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const AdminUsersScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: products.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final p = products[i];
          return ListTile(
            leading: ClipRRect(
              borderRadius:
                  BorderRadius.circular(999),
              child: Image.asset(
                p.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(p.name),
            subtitle: Text(
              '${p.price.toStringAsFixed(0)} RSD',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      _openProductForm(context,
                          existing: p),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    productsProvider
                        .deleteProduct(p.id);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          '${p.name} je obrisan.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () => _openProductForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
