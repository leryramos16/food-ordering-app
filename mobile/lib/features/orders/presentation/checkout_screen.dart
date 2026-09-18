import 'package:flutter/material.dart';

import '../../addresses/domain/address.dart';
import '../../addresses/state/address_controller.dart';
import '../../cart/state/cart_controller.dart';
import '../state/checkout_controller.dart';
import 'dragonpay_payment_screen.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.cartController,
    required this.addressController,
    required this.checkoutController,
  });

  final CartController cartController;
  final AddressController addressController;
  final CheckoutController checkoutController;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _notes = TextEditingController();
  int? _selectedAddressId;
  String _paymentMethod = 'cash_on_delivery';

  @override
  void initState() {
    super.initState();

    widget.addressController.loadAddresses();
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          widget.addressController,
          widget.checkoutController,
        ]),
        builder: (context, _) {
          final addressController = widget.addressController;
          final cart = widget.cartController;

          if (addressController.isLoading && addressController.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (addressController.addresses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_off_outlined, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Add a delivery address before checking out.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go back'),
                    ),
                  ],
                ),
              ),
            );
          }

          _selectedAddressId ??= addressController.addresses
              .firstWhere(
                (address) => address.isDefault,
                orElse: () => addressController.addresses.first,
              )
              .id;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Deliver to',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              RadioGroup<int>(
                groupValue: _selectedAddressId,
                onChanged: (value) =>
                    setState(() => _selectedAddressId = value),
                child: Column(
                  children: [
                    for (final address in addressController.addresses)
                      _AddressOption(
                        address: address,
                        selected: address.id == _selectedAddressId,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Order notes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notes,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. No onions, leave at the gate (optional)',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Payment method',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              RadioGroup<String>(
                groupValue: _paymentMethod,
                onChanged: (value) {
                  if (value != null) setState(() => _paymentMethod = value);
                },
                child: Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: _paymentMethod == 'cash_on_delivery'
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: const RadioListTile<String>(
                        value: 'cash_on_delivery',
                        secondary: Icon(Icons.payments_outlined),
                        title: Text('Cash on delivery'),
                      ),
                    ),
                    Card(
                      color: _paymentMethod == 'gcash'
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: const RadioListTile<String>(
                        value: 'gcash',
                        secondary: Icon(Icons.account_balance_wallet_outlined),
                        title: Text('GCash'),
                        subtitle: Text('via Dragonpay'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _summaryRow(context, 'Subtotal', cart.subtotal),
                      _summaryRow(context, 'Delivery fee', cart.deliveryFee),
                      const Divider(height: 20),
                      _summaryRow(context, 'Total', cart.total, emphasize: true),
                    ],
                  ),
                ),
              ),
              if (widget.checkoutController.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.checkoutController.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: widget.checkoutController.isSubmitting
                    ? null
                    : _placeOrder,
                child: widget.checkoutController.isSubmitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _paymentMethod == 'gcash'
                            ? 'Pay with GCash'
                            : 'Place order',
                      ),
              ),
            ],
          );
        },
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
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
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

  Future<void> _placeOrder() async {
    final addressId = _selectedAddressId;
    if (addressId == null) return;

    var order = await widget.checkoutController.placeOrder(
      cart: widget.cartController,
      addressId: addressId,
      paymentMethod: _paymentMethod,
      notes: _notes.text,
    );

    if (order == null || !mounted) return;

    if (_paymentMethod == 'gcash') {
      final paymentUrl = await widget.checkoutController.initiateGcashPayment(
        order.id,
      );

      if (paymentUrl != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DragonpayPaymentScreen(paymentUrl: paymentUrl),
          ),
        );

        // The WebView screen closed (customer finished or backed out of
        // GCash) — re-fetch the order so we show its real payment_status,
        // which was updated server-to-server by Dragonpay's postback.
        order = await widget.checkoutController.refreshOrder(order.id) ?? order;
      }
    }

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => OrderConfirmationScreen(order: order!)),
        (route) => route.isFirst,
      );
    }
  }
}

class _AddressOption extends StatelessWidget {
  const _AddressOption({required this.address, required this.selected});

  final Address address;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: selected ? colorScheme.primaryContainer : null,
      child: RadioListTile<int>(
        value: address.id,
        title: Text(address.label),
        subtitle: Text(
          '${address.recipientName} • ${address.phone}\n'
          '${address.addressLine}, ${address.city}',
        ),
        isThreeLine: true,
      ),
    );
  }
}
