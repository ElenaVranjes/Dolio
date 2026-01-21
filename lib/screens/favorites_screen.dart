import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/product_grid.dart';
import 'auth_screen.dart';

class FavoritesScreen extends StatelessWidget {
  static const routeName = '/favorites';

  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (!auth.isAuth) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Omiljeni proizvodi'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Lista omiljenih proizvoda je dostupna samo ulogovanim korisnicima.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AuthScreen.routeName);
                  },
                  child: const Text('Prijava / Registracija'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final favorites =
        Provider.of<ProductsProvider>(context).favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Omiljeni proizvodi'),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text('Još uvek nemate omiljene proizvode.'),
            )
          : ProductGrid(products: favorites),
    );
  }
}
