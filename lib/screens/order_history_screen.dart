import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = "demo_user_123";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final data = orderDoc.data() as Map<String, dynamic>;
              final items = List<Map<String, dynamic>>.from(data['items']);
              final totalPrice = data['totalPrice'] as double;
              final createdAt = data['createdAt'] as Timestamp;
              final orderId = data['id'] as String;

              return Card(
                margin: const EdgeInsets.all(12),
                child: ExpansionTile(
                  leading: const Icon(Icons.receipt),
                  title: Text('Order #${orderId.substring(0, 8)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: \$${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Date: ${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}',
                      ),
                    ],
                  ),
                  children: items.map((item) {
                    return ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: Text(item['productName']),
                      subtitle: Text('Quantity: ${item['quantity']}'),
                      trailing: Text(
                        '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}