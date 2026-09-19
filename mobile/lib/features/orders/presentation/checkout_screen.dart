import 'package:flutter/material.dart';

import '../../addresses/domain/address.dart';
import '../../addresses/presentation/address_list_screen.dart';
import '../../addresses/state/address_controller.dart';
import '../../auth/domain/app_user.dart';
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
    required this.currentUser,
  });

  final CartController cartController;
  final AddressController addressController;
  final CheckoutController checkoutController;
  final AppUser? currentUser;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notes = TextEditingController();
  final _contactName = TextEditingController();
  final _contactPhone = TextEditingController();
  int? _selectedAddressId;
  String _paymentMethod = 'cash_on_delivery';
  String _fulfillmentType = 'delivery';
  DateTime? _requestedDate;
  TimeOfDay? _requestedTime;
  String? _dateError;
  String? _timeError;

  @override
  void initState() {
    super.initState();

    widget.addressController.loadAddresses();

    // Contact info is bound to the account by default — the customer can
    // still edit it, since the account holder isn't always the right
    // person to reach (e.g. ordering as a gift for someone else).
    _contactName.text = widget.currentUser?.name ?? '';
    _contactPhone.text = widget.currentUser?.phone ?? '';
  }

  @override
  void dispose() {
    _notes.dispose();
    _contactName.dispose();
    _contactPhone.dispose();
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
          final isPreorder = cart.requiresPreorderDate;
          final needsAddress = !isPreorder || _fulfillmentType == 'delivery';

          // A pickup-only pre-order never needs an address, so only the
          // classic (non-preorder, always-delivery) flow blocks on this.
          if (!isPreorder) {
            if (addressController.isLoading &&
                addressController.addresses.isEmpty) {
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
          }

          if (addressController.addresses.isNotEmpty) {
            _selectedAddressId ??= addressController.addresses
                .firstWhere(
                  (address) => address.isDefault,
                  orElse: () => addressController.addresses.first,
                )
                .id;
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (isPreorder) ...[
                  Text(
                    'When do you want this?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This order includes a pre-order item — pick a date at '
                    'least ${cart.requiredPreorderLeadDays} day(s) from now.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.event_outlined),
                            title: Text(
                              _requestedDate == null
                                  ? 'Date'
                                  : _formatDate(_requestedDate!),
                            ),
                            onTap: () => _pickRequestedDate(
                              cart.requiredPreorderLeadDays,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.access_time_outlined),
                            title: Text(
                              _requestedTime == null
                                  ? 'Time'
                                  : _requestedTime!.format(context),
                            ),
                            onTap: _pickRequestedTime,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_dateError != null || _timeError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _dateError ?? _timeError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Fulfillment',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RadioGroup<String>(
                    groupValue: _fulfillmentType,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _fulfillmentType = value);
                      }
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: _fulfillmentType == 'delivery'
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
                            child: const RadioListTile<String>(
                              value: 'delivery',
                              secondary: Icon(Icons.delivery_dining_outlined),
                              title: Text('Delivery'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Card(
                            color: _fulfillmentType == 'pickup'
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
                            child: const RadioListTile<String>(
                              value: 'pickup',
                              secondary: Icon(Icons.storefront_outlined),
                              title: Text('Pickup'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Contact info',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Who should the restaurant reach about this order?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _contactName,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a contact name.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contactPhone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (value) {
                      final phone = value?.trim() ?? '';
                      return RegExp(r'^09\d{9}$').hasMatch(phone)
                          ? null
                          : 'Enter a valid PH mobile number (09XXXXXXXXX).';
                    },
                  ),
                ],
                if (needsAddress) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Deliver to',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (addressController.addresses.isEmpty)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.add_location_alt_outlined),
                        title: const Text('Add a delivery address'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddressListScreen(
                              controller: addressController,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
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
                ],
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
                  decoration: const InputDecoration(hintText: '(Optional)'),
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
                          secondary: Icon(
                            Icons.account_balance_wallet_outlined,
                          ),
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
                        _summaryRow(
                          context,
                          'Total',
                          cart.total,
                          emphasize: true,
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.checkoutController.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.checkoutController.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
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
            ),
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

  String _formatDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  String _formatTimeOfDay(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickRequestedDate(int leadDays) async {
    final earliest = DateTime.now().add(Duration(days: leadDays));

    final picked = await showDatePicker(
      context: context,
      initialDate: _requestedDate ?? earliest,
      firstDate: earliest,
      lastDate: earliest.add(const Duration(days: 90)),
    );

    if (picked != null) {
      setState(() {
        _requestedDate = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _pickRequestedTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _requestedTime ?? const TimeOfDay(hour: 12, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _requestedTime = picked;
        _timeError = null;
      });
    }
  }

  Future<void> _placeOrder() async {
    final cart = widget.cartController;
    final isPreorder = cart.requiresPreorderDate;

    if (isPreorder) {
      if (!_formKey.currentState!.validate()) return;

      var hasScheduleError = false;

      if (_requestedDate == null) {
        setState(() => _dateError = 'Pick a date for this order.');
        hasScheduleError = true;
      }

      if (_requestedTime == null) {
        setState(() => _timeError = 'Pick a time for this order.');
        hasScheduleError = true;
      }

      if (hasScheduleError) return;
    }

    final needsAddress = !isPreorder || _fulfillmentType == 'delivery';
    if (needsAddress && _selectedAddressId == null) return;

    var order = await widget.checkoutController.placeOrder(
      cart: cart,
      addressId: needsAddress ? _selectedAddressId : null,
      paymentMethod: _paymentMethod,
      notes: _notes.text,
      requestedDate: isPreorder ? _requestedDate : null,
      requestedTime: isPreorder && _requestedTime != null
          ? _formatTimeOfDay(_requestedTime!)
          : null,
      fulfillmentType: isPreorder ? _fulfillmentType : null,
      contactName: isPreorder ? _contactName.text : null,
      contactPhone: isPreorder ? _contactPhone.text : null,
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
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(order: order!),
        ),
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
