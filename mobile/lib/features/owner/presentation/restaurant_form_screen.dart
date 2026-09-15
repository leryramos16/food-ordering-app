import 'package:flutter/material.dart';

import '../../restaurants/domain/restaurant.dart';
import '../state/owner_restaurant_controller.dart';

class RestaurantFormScreen extends StatefulWidget {
  const RestaurantFormScreen({super.key, required this.controller});

  final OwnerRestaurantController controller;

  @override
  State<RestaurantFormScreen> createState() => _RestaurantFormScreenState();
}

class _RestaurantFormScreenState extends State<RestaurantFormScreen> {
  final _formKey = GlobalKey<FormState>();

  Restaurant? get _existing => widget.controller.restaurant;

  late final _name = TextEditingController(text: _existing?.name);
  late final _description = TextEditingController(text: _existing?.description);
  late final _phone = TextEditingController(text: _existing?.phone);
  late final _address = TextEditingController(text: _existing?.address);
  late final _deliveryFee = TextEditingController(
    text: _existing?.deliveryFee.toStringAsFixed(2),
  );
  late final _minimumOrder = TextEditingController(
    text: _existing?.minimumOrder.toStringAsFixed(2),
  );
  late bool _isOpen = _existing?.isOpen ?? true;

  bool get _isEditing => _existing != null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _phone.dispose();
    _address.dispose();
    _deliveryFee.dispose();
    _minimumOrder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit restaurant' : 'Create your restaurant'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Restaurant name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a name.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone (optional)'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the restaurant address.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _deliveryFee,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Delivery fee'),
                  validator: _validateMoney,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _minimumOrder,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Minimum order'),
                  validator: _validateMoney,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Open for orders'),
                  value: _isOpen,
                  onChanged: (value) => setState(() => _isOpen = value),
                ),
                if (widget.controller.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.controller.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: widget.controller.isSubmitting ? null : _submit,
                  child: widget.controller.isSubmitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Save changes' : 'Create restaurant'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateMoney(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter an amount.';
    final parsed = double.tryParse(value);
    if (parsed == null || parsed < 0) return 'Enter a valid amount.';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.controller.saveRestaurant(
      name: _name.text,
      description: _description.text,
      phone: _phone.text,
      address: _address.text,
      deliveryFee: double.parse(_deliveryFee.text),
      minimumOrder: double.parse(_minimumOrder.text),
      isOpen: _isOpen,
    );

    if (success && mounted) Navigator.of(context).pop();
  }
}
