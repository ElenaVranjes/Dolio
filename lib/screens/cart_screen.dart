import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    if (!auth.isAuth) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Za rad sa korpom morate biti prijavljeni.',
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
      );
    }

    final cartItems = cart.items.values.toList();

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('Ukupno'),
                const Spacer(),
                Chip(
                  label: Text(
                    '${cart.totalAmount.toStringAsFixed(0)} RSD',
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: cart.itemCount == 0
                      ? null
                      : () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Simulacija kreiranja narudžbine...'),
                            ),
                          );
                          cart.clear();
                        },
                  child: const Text('Plati'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: cartItems.isEmpty
              ? const Center(
                  child: Text('Korpa je prazna.'),
                )
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (ctx, i) {
                    final item = cartItems[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            if (item.size != null ||
                                item.color != null)
                              Text(
                                '${item.size != null ? 'Veličina: ${item.size}' : ''}'
                                '${item.size != null && item.color != null ? ' • ' : ''}'
                                '${item.color != null ? 'Boja: ${item.color}' : ''}',
                              ),
                            Text(
                              'Cena: ${item.price.toStringAsFixed(0)} RSD',
                            ),
                          ],
                        ),
                        leading: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              cart.removeItem(item.id),
                        ),
                        trailing: SizedBox(
                          width: 110,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () =>
                                    cart.decreaseQuantity(
                                        item.id),
                              ),
                              Text(item.quantity.toString()),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () =>
                                    cart.increaseQuantity(
                                        item.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
