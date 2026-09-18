import 'package:flutter/material.dart';

import '../../addresses/state/address_controller.dart';
import '../../auth/domain/app_user.dart';
import '../../orders/presentation/checkout_screen.dart';
import '../../orders/state/checkout_controller.dart';
import '../state/cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.controller,
    required this.addressController,
    required this.checkoutController,
    required this.currentUser,
  });

  final CartController controller;
  final AddressController addressController;
  final CheckoutController checkoutController;
  final AppUser? currentUser;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(controller.restaurantName ?? 'Your cart')),
          body: controller.isEmpty
              ? const Center(child: Text('Your cart is empty.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.items.length,
                        separatorBuilder: (_, _) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          final cartItem = controller.items[index];

                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.menuItem.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₱${cartItem.menuItem.price.toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                              ),
                              _QuantityStepper(
                                quantity: cartItem.quantity,
                                onIncrement: () => controller.incrementQuantity(
                                  cartItem.menuItem.id,
                                ),
                                onDecrement: () => controller.decrementQuantity(
                                  cartItem.menuItem.id,
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 72,
                                child: Text(
                                  '₱${cartItem.lineTotal.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    _CartSummary(
                      controller: controller,
                      addressController: addressController,
                      checkoutController: checkoutController,
                      currentUser: currentUser,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove, size: 16),
          visualDensity: VisualDensity.compact,
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton.filledTonal(
          onPressed: onIncrement,
          icon: const Icon(Icons.add, size: 16),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.controller,
    required this.addressController,
    required this.checkoutController,
    required this.currentUser,
  });

  final CartController controller;
  final AddressController addressController;
  final CheckoutController checkoutController;
  final AppUser? currentUser;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _summaryRow(context, 'Subtotal', controller.subtotal),
            _summaryRow(context, 'Delivery fee', controller.deliveryFee),
            const Divider(height: 20),
            _summaryRow(context, 'Total', controller.total, emphasize: true),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CheckoutScreen(
                    cartController: controller,
                    addressController: addressController,
                    checkoutController: checkoutController,
                    currentUser: currentUser,
                  ),
                ),
              ),
              child: const Text('Proceed to checkout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
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
}
