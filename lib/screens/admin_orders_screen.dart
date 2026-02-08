import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart';
import '../models/order.dart';

class AdminOrdersScreen extends StatefulWidget {
  static const routeName = '/admin-orders';

  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  bool _initialized = false;

  static const List<String> _statusOptions = [
    'Na čekanju',
    'Plaćeno',
    'Poslato',
    'Otkazano',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      Provider.of<OrdersProvider>(context, listen: false)
          .fetchAllOrders();
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersProv = Provider.of<OrdersProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sve narudžbine'),
      ),
      body: ordersProv.isLoadingAdmin
          ? const Center(child: CircularProgressIndicator())
          : ordersProv.allOrders.isEmpty
              ? const Center(
                  child: Text('Nema zabeleženih narudžbina.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ordersProv.allOrders.length,
                  itemBuilder: (ctx, i) {
                    final order = ordersProv.allOrders[i];
                    return _AdminOrderCard(
                      order: order,
                      onStatusChanged: (newStatus) {
                        Provider.of<OrdersProvider>(context,
                                listen: false)
                            .updateOrderStatus(order.id, newStatus);
                      },
                    );
                  },
                ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final Order order;
  final ValueChanged<String> onStatusChanged;

  const _AdminOrderCard({
    required this.order,
    required this.onStatusChanged,
  });

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd.$mm.$yyyy. $hh:$min';
  }

  @override
  Widget build(BuildContext context) {
    const statusOptions = [
      'Na čekanju',
      'Plaćeno',
      'Poslato',
      'Otkazano',
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          '${order.userName} • ${order.totalAmount.toStringAsFixed(0)} RSD',
        ),
        subtitle: Text(
          '${order.status} • ${_formatDate(order.createdAt)}',
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
                      'Status: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: order.status,
                      items: statusOptions
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        onStatusChanged(val);
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
