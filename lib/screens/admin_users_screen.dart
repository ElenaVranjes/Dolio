import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminUsersScreen extends StatelessWidget {
  static const routeName = '/admin-users';

  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrovani korisnici'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db
            .collection('users')
            .orderBy('createdAt', descending: false)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nema registrovanih korisnika.'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final data = docs[i].data();
              final fullName = (data['fullName'] ?? '') as String;
              final email = (data['email'] ?? '') as String;
              final phone = (data['phone'] ?? '') as String;
              final isAdmin = (data['isAdmin'] ?? false) as bool;

              final displayName =
                  fullName.isNotEmpty ? fullName : email;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?',
                  ),
                ),
                title: Text(displayName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (email.isNotEmpty) Text(email),
                    if (phone.isNotEmpty) Text('Tel: $phone'),
                  ],
                ),
                trailing: Chip(
                  label: Text(isAdmin ? 'Admin' : 'Korisnik'),
                  backgroundColor:
                      isAdmin ? Colors.redAccent : Colors.grey.shade700,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
