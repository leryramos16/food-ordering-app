import 'package:flutter/material.dart';

import '../domain/order.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 44,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Order placed!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  order.orderNumber,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (final item in order.items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text('${item.quantity}x '),
                                Expanded(child: Text(item.name)),
                                Text('₱${item.lineTotal.toStringAsFixed(2)}'),
                              ],
                            ),
                          ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '₱${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Delivering to ${order.addressLine}, ${order.city}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Back to restaurants'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
