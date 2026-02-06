import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/orders_provider.dart';
import '../models/order.dart';

class AdminOrdersScreen extends StatefulWidget {
  static const routeName = '/admin-orders';

  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() =>
      _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final orders =
          Provider.of<OrdersProvider>(context, listen: false);
      orders.fetchAllOrders();
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final ordersProv = Provider.of<OrdersProvider>(context);

    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Narudžbine'),
        ),
        body: const Center(
          child: Text('Samo administrator ima pristup ovom ekranu.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sve narudžbine'),
      ),
      body: ordersProv.isLoadingAdmin
          ? const Center(child: CircularProgressIndicator())
          : ordersProv.allOrders.isEmpty
              ? const Center(
                  child: Text(
                    'Još uvek nema nijedne narudžbine.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ordersProv.allOrders.length,
                  itemBuilder: (ctx, i) {
                    final order = ordersProv.allOrders[i];
                    return _AdminOrderCard(order: order);
                  },
                ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final Order order;

  const _AdminOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final ordersProv =
        Provider.of<OrdersProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          '${order.fullName} • ${order.totalAmount.toStringAsFixed(0)} RSD',
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
                Text('Korisnik: ${order.userName}'),
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
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: order.status,
                      items: const [
                        'Na čekanju',
                        'Plaćeno',
                        'Poslato',
                        'Otkazano',
                      ].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        ordersProv.updateOrderStatus(
                          order.id,
                          value,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
