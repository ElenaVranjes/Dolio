import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/orders_provider.dart';
import '../models/order.dart' as model; // ⬅ alias

class OrderHistoryScreen extends StatefulWidget {
  static const routeName = '/orders';

  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String? _lastUserId;
  bool _requestedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orders = Provider.of<OrdersProvider>(context, listen: false);

    // Ako nije ulogovan – ne radi ništa
    if (!auth.isAuth || auth.userId.isEmpty) {
      _lastUserId = null;
      _requestedOnce = false;
      return;
    }

    // Ako se promenio korisnik ili prvi put ulazimo – povuci njegove narudžbine
    if (auth.userId != _lastUserId || !_requestedOnce) {
      _lastUserId = auth.userId;
      _requestedOnce = true;
      orders.fetchUserOrders(auth.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final ordersProv = Provider.of<OrdersProvider>(context);

    if (!auth.isAuth) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Istorija narudžbina'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Za prikaz istorije narudžbina potrebno je da se prijavite.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Istorija narudžbina'),
      ),
      body: ordersProv.isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : ordersProv.userOrders.isEmpty
              ? const Center(
                  child: Text(
                    'Nemate prethodnih narudžbina.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ordersProv.userOrders.length,
                  itemBuilder: (ctx, i) {
                    final model.Order order = ordersProv.userOrders[i];
                    return _OrderCard(order: order);
                  },
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final model.Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          'Ukupno: ${order.totalAmount.toStringAsFixed(0)} RSD',
        ),
        subtitle: Text(
          '${order.status} • ${order.createdAt}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ime i prezime: ${order.fullName}'),
                Text('Adresa: ${order.address}'),
                Text('Telefon: ${order.phone}'),
                const SizedBox(height: 8),
                const Text(
                  'Stavke:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...order.items.map(
                  (item) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.name} x${item.quantity}',
                        ),
                      ),
                      Text(
                        '${item.price.toStringAsFixed(0)} RSD',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
