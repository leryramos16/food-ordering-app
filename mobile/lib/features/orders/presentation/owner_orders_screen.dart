import 'package:flutter/material.dart';

import '../domain/order.dart';
import '../state/owner_order_controller.dart';

class OwnerOrdersScreen extends StatefulWidget {
  const OwnerOrdersScreen({super.key, required this.controller});

  final OwnerOrderController controller;

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
  @override
  void initState() {
    super.initState();

    widget.controller.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final controller = widget.controller;

          if (controller.isLoading && controller.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null && controller.orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(controller.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: controller.loadOrders,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.orders.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }

          return RefreshIndicator(
            onRefresh: controller.loadOrders,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _OrderCard(
                order: controller.orders[index],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${order.recipientName} • ${order.recipientPhone}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${order.addressLine}, ${order.city}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 20),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
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
                Text(
                  order.paymentMethod == 'cash_on_delivery'
                      ? 'Cash on delivery'
                      : order.paymentMethod,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '₱${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Note: ${order.notes}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'pending' => Colors.orange,
      'preparing' => Colors.blue,
      'ready' || 'completed' => Colors.green,
      'cancelled' => Colors.red,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          color: color.shade700,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
