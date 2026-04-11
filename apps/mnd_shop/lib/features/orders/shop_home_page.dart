import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mnd_core/mnd_core.dart';

import '../../data/order_repository.dart';
import 'create_order_page.dart';

class ShopHomePage extends StatelessWidget {
  const ShopHomePage({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final repo = OrderRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop orders'),
        actions: [
          TextButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: repo.ordersForShop(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load orders.\n${snapshot.error}\n'
                  'If this mentions an index, deploy firebase/firestore.indexes.json.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('No orders yet. Create one with +.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = docs[i];
              final m = d.data();
              final status = orderStatusFromKey(m['status'] as String?) ??
                  OrderStatus.pending;
              return Card(
                child: ListTile(
                  title: Text('Order ${d.id.substring(0, 8)}…'),
                  subtitle: Text(
                    'Total ${m['total_amount']} LKR · '
                    'Admin ${m['admin_earning']} · '
                    'Rider ${m['rider_earning']} · ${status.name}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => const CreateOrderPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
