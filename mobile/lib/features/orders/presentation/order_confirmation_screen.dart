import 'package:flutter/material.dart';

import '../domain/order.dart';
import 'preorder_badge.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isGcash = order.paymentMethod == 'gcash';

    final (icon, iconColor, title, subtitle) = switch (order.paymentStatus) {
      'paid' => (
        Icons.check_circle_outline,
        Colors.green,
        'Payment received!',
        'Your GCash payment went through.',
      ),
      'failed' => (
        Icons.error_outline,
        colorScheme.error,
        'Payment didn\'t go through',
        'You can try paying again from your order, or contact the restaurant.',
      ),
      _ when isGcash => (
        Icons.hourglass_top_outlined,
        Colors.orange,
        'Payment pending',
        'We\'re still waiting for GCash to confirm. This can take a moment.',
      ),
      _ => (
        Icons.check_circle_outline,
        colorScheme.primary,
        'Order placed!',
        'Pay with cash when your order arrives.',
      ),
    };

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
                  backgroundColor: iconColor.withValues(alpha: 0.15),
                  child: Icon(icon, size: 44, color: iconColor),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  order.orderNumber,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (order.isPreorder && order.requestedDate != null) ...[
                  const SizedBox(height: 8),
                  PreorderBadge(
                    date: order.requestedDate!,
                    time: order.requestedTime,
                    fulfillmentType: order.fulfillmentType,
                  ),
                ],
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  order.isPickup
                      ? "You'll pick this up at the restaurant."
                      : 'Delivering to ${order.fullAddress}',
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
