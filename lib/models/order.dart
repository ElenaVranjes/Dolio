import 'package:cloud_firestore/cloud_firestore.dart' as fs;

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final String id;
  final String userId;
  final String userName; // auth.displayName
  final String fullName;
  final String address;
  final String phone;
  final double totalAmount;
  final String status; // "Na čekanju", "Plaćeno", "Poslato", "Otkazano"
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.fullName,
    required this.address,
    required this.phone,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromFirestore(
    fs.DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final itemsData = data['items'] as List<dynamic>? ?? const [];

    return Order(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      status: data['status'] as String? ?? 'Na čekanju',
      createdAt: (data['createdAt'] as fs.Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      items: itemsData
          .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'fullName': fullName,
      'address': address,
      'phone': phone,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': fs.Timestamp.fromDate(createdAt),
      'items': items.map((e) => e.toMap()).toList(),
    };
  }
}
