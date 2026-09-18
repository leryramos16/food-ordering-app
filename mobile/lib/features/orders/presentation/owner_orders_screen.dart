import 'package:flutter/material.dart';

import '../domain/order.dart';
import '../state/owner_order_controller.dart';
import 'owner_order_detail_screen.dart';
import 'status_chip.dart';

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
                controller: controller,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.controller});

  final Order order;
  final OwnerOrderController controller;

  /// Mirrors the backend's allowed status transitions (see
  /// OwnerOrderController::STATUS_TRANSITIONS) so the buttons shown here
  /// only ever offer moves the server will actually accept.
  static const Map<
    String,
    List<(String label, String target, bool destructive)>
  >
  _nextActions = {
    'pending': [
      ('Start preparing', 'preparing', false),
      ('Cancel order', 'cancelled', true),
    ],
    'preparing': [
      ('Mark ready', 'ready', false),
      ('Cancel order', 'cancelled', true),
    ],
    'ready': [('Mark delivered', 'delivered', false)],
    'delivered': [],
    'cancelled': [],
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                OwnerOrderDetailScreen(order: order, controller: controller),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.id}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  StatusChip(status: order.status),
                ],
              ),
              Text(
                order.orderNumber,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 15,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.recipientName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
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
              if (_hasActions) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_canMarkPaid)
                      FilledButton.tonalIcon(
                        onPressed: _isSubmitting
                            ? null
                            : () => _markPaid(context),
                        icon: const Icon(Icons.payments_outlined, size: 16),
                        label: const Text('Mark paid'),
                      ),
                    for (final (label, target, destructive)
                        in _actionsForStatus)
                      destructive
                          ? OutlinedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => _updateStatus(context, target),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              child: Text(label),
                            )
                          : FilledButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => _updateStatus(context, target),
                              child: Text(label),
                            ),
                    if (_isSubmitting)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<(String, String, bool)> get _actionsForStatus =>
      _nextActions[order.status] ?? const [];

  bool get _canMarkPaid =>
      order.paymentMethod == 'cash_on_delivery' &&
      order.paymentStatus == 'unpaid';

  bool get _hasActions => _actionsForStatus.isNotEmpty || _canMarkPaid;

  bool get _isSubmitting => controller.submittingOrderIds.contains(order.id);

  Future<void> _updateStatus(BuildContext context, String target) async {
    final success = await controller.updateStatus(order.id, target);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Something went wrong.'),
        ),
      );
    }
  }

  Future<void> _markPaid(BuildContext context) async {
    final success = await controller.markPaid(order.id);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Something went wrong.'),
        ),
      );
    }
  }
}
