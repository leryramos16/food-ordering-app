import 'package:flutter/material.dart';

import '../domain/order.dart';
import '../state/owner_order_controller.dart';
import 'preorder_badge.dart';
import 'status_chip.dart';

class OwnerOrderDetailScreen extends StatelessWidget {
  const OwnerOrderDetailScreen({
    super.key,
    required this.order,
    required this.controller,
  });

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

  /// The live version of this order from the controller's list, so status
  /// changes made here (or a Dragonpay postback that lands in the
  /// background) show up immediately without leaving this screen.
  Order _current() {
    return controller.orders.firstWhere(
      (candidate) => candidate.id == order.id,
      orElse: () => order,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final current = _current();
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(title: Text('Order #${current.id}')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  StatusChip(status: current.status),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      current.orderNumber,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (current.placedAt != null)
                    Text(
                      _formatDate(current.placedAt!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              if (current.isPreorder && current.requestedDate != null) ...[
                const SizedBox(height: 10),
                PreorderBadge(
                  date: current.requestedDate!,
                  time: current.requestedTime,
                  fulfillmentType: current.fulfillmentType,
                ),
              ],
              const SizedBox(height: 20),

              _SectionCard(
                icon: Icons.person_outline,
                title: 'Customer',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current.recipientName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.call_outlined,
                                size: 15,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(current.recipientPhone),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                current.isPickup
                                    ? Icons.storefront_outlined
                                    : Icons.location_on_outlined,
                                size: 15,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  current.isPickup
                                      ? 'Picking up at the restaurant'
                                      : current.fullAddress,
                                ),
                              ),
                            ],
                          ),
                          if (current.contactName != null &&
                              current.contactPhone != null) ...[
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Text(
                              'Order contact',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${current.contactName} • ${current.contactPhone}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              _SectionCard(
                icon: Icons.receipt_long_outlined,
                title: 'Items',
                child: Column(
                  children: [
                    for (final item in current.items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${item.quantity}x',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(item.name)),
                            Text('₱${item.lineTotal.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    const Divider(height: 24),
                    _moneyRow(context, 'Subtotal', current.subtotal),
                    _moneyRow(context, 'Delivery fee', current.deliveryFee),
                    const Divider(height: 20),
                    _moneyRow(
                      context,
                      'Total',
                      current.totalAmount,
                      emphasize: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              _SectionCard(
                icon: Icons.payments_outlined,
                title: 'Payment',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      current.paymentMethod == 'cash_on_delivery'
                          ? 'Cash on delivery'
                          : 'GCash',
                    ),
                    _PaymentStatusBadge(status: current.paymentStatus),
                  ],
                ),
              ),

              if (current.notes != null && current.notes!.isNotEmpty) ...[
                const SizedBox(height: 14),
                _SectionCard(
                  icon: Icons.sticky_note_2_outlined,
                  title: 'Note from customer',
                  child: Text(current.notes!),
                ),
              ],

              if (_hasActions(current)) ...[
                const SizedBox(height: 24),
                Text(
                  'Update order',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                if (_canMarkPaid(current))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FilledButton.tonalIcon(
                      onPressed: _isSubmitting(current)
                          ? null
                          : () => _markPaid(context, current),
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Mark paid'),
                    ),
                  ),
                for (final (label, target, destructive) in _actionsForStatus(
                  current,
                ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: destructive
                        ? SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _isSubmitting(current)
                                  ? null
                                  : () =>
                                        _updateStatus(context, current, target),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.error,
                                side: BorderSide(color: colorScheme.error),
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: Text(label),
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _isSubmitting(current)
                                  ? null
                                  : () =>
                                        _updateStatus(context, current, target),
                              child: Text(label),
                            ),
                          ),
                  ),
                if (_isSubmitting(current))
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _moneyRow(
    BuildContext context,
    String label,
    double amount, {
    bool emphasize = false,
  }) {
    final style = emphasize
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('₱${amount.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }

  List<(String, String, bool)> _actionsForStatus(Order order) =>
      _nextActions[order.status] ?? const [];

  bool _canMarkPaid(Order order) =>
      order.paymentMethod == 'cash_on_delivery' &&
      order.paymentStatus == 'unpaid';

  bool _hasActions(Order order) =>
      _actionsForStatus(order).isNotEmpty || _canMarkPaid(order);

  bool _isSubmitting(Order order) =>
      controller.submittingOrderIds.contains(order.id);

  Future<void> _updateStatus(
    BuildContext context,
    Order order,
    String target,
  ) async {
    final success = await controller.updateStatus(order.id, target);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Something went wrong.'),
        ),
      );
    }
  }

  Future<void> _markPaid(BuildContext context, Order order) async {
    final success = await controller.markPaid(order.id);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Something went wrong.'),
        ),
      );
    }
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final period = local.hour < 12 ? 'AM' : 'PM';
    final minute = local.minute.toString().padLeft(2, '0');

    return '${_months[local.month - 1]} ${local.day}, $hour12:$minute $period';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

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
                Icon(icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (icon, color, label) = switch (status) {
      'paid' => (Icons.check_circle, Colors.green, 'Paid'),
      'failed' => (Icons.error, Colors.red, 'Failed'),
      'pending' => (Icons.hourglass_top, Colors.orange, 'Pending'),
      _ => (
        Icons.radio_button_unchecked,
        colorScheme.onSurfaceVariant,
        'Unpaid',
      ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
