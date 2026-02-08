import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/order.dart' as order_model;

class OrdersProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoadingUser = false;
  bool _isLoadingAdmin = false;

  final List<order_model.Order> _userOrders = [];
  final List<order_model.Order> _allOrders = [];

  bool get isLoadingUser => _isLoadingUser;
  bool get isLoadingAdmin => _isLoadingAdmin;

  List<order_model.Order> get userOrders =>
      List.unmodifiable(_userOrders);
  List<order_model.Order> get allOrders =>
      List.unmodifiable(_allOrders);

  Future<void> createOrder({
    required String userId,
    required String userName,
    required String fullName,
    required String address,
    required String phone,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final docRef = await _db.collection('orders').add({
        'userId': userId,
        'userName': userName,
        'fullName': fullName,
        'address': address,
        'phone': phone,
        'totalAmount': totalAmount,
        'status': 'Na čekanju',
        'createdAt': Timestamp.now(),
        'items': items,
      });

      if (kDebugMode) {
        print('Narudžbina kreirana: ${docRef.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Greška pri kreiranju narudžbine: $e');
      }
      rethrow;
    }
  }

  Future<void> fetchUserOrders(String userId) async {
    if (userId.isEmpty) return;

    _isLoadingUser = true;
    notifyListeners();

    try {
      final snap = await _db
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _userOrders
        ..clear()
        ..addAll(
          snap.docs
              .map((doc) => order_model.Order.fromFirestore(doc)),
        );
    } catch (e) {
      if (kDebugMode) {
        print('Greška pri čitanju korisničkih narudžbina: $e');
      }
    } finally {
      _isLoadingUser = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllOrders() async {
    _isLoadingAdmin = true;
    notifyListeners();

    try {
      final snap = await _db
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      _allOrders
        ..clear()
        ..addAll(
          snap.docs
              .map((doc) => order_model.Order.fromFirestore(doc)),
        );
    } catch (e) {
      if (kDebugMode) {
        print('Greška pri čitanju svih narudžbina: $e');
      }
    } finally {
      _isLoadingAdmin = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _db
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});

      void updateList(List<order_model.Order> list) {
        final index = list.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          final old = list[index];
          list[index] = order_model.Order(
            id: old.id,
            userId: old.userId,
            userName: old.userName,
            fullName: old.fullName,
            address: old.address,
            phone: old.phone,
            totalAmount: old.totalAmount,
            status: newStatus,
            createdAt: old.createdAt,
            items: old.items,
          );
        }
      }

      updateList(_allOrders);
      updateList(_userOrders);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Greška pri promeni statusa narudžbine: $e');
      }
      rethrow;
    }
  }
}
