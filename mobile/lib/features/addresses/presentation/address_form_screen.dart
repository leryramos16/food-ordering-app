import 'package:flutter/material.dart';

import '../domain/address.dart';
import '../state/address_controller.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key, required this.controller, this.address});

  final AddressController controller;

  /// Null when adding a new address, non-null when editing an existing one.
  final Address? address;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _label = TextEditingController(text: widget.address?.label);
  late final _recipientName = TextEditingController(
    text: widget.address?.recipientName,
  );
  late final _phone = TextEditingController(text: widget.address?.phone);
  late final _addressLine = TextEditingController(
    text: widget.address?.addressLine,
  );
  late final _barangay = TextEditingController(text: widget.address?.barangay);
  late final _city = TextEditingController(text: widget.address?.city);
  late final _province = TextEditingController(text: widget.address?.province);
  late final _postalCode = TextEditingController(
    text: widget.address?.postalCode,
  );
  late bool _isDefault = widget.address?.isDefault ?? false;

  bool get _isEditing => widget.address != null;

  @override
  void dispose() {
    _label.dispose();
    _recipientName.dispose();
    _phone.dispose();
    _addressLine.dispose();
    _barangay.dispose();
    _city.dispose();
    _province.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit address' : 'Add address'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _label,
                  decoration: const InputDecoration(
                    labelText: 'Label (e.g. Home, Work)',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a label.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _recipientName,
                  decoration: const InputDecoration(labelText: 'Recipient name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the recipient name.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a phone number.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _addressLine,
                  decoration: const InputDecoration(labelText: 'Address line'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the street address.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _barangay,
                  decoration: const InputDecoration(
                    labelText: 'Barangay (optional)',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _city,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the city.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _province,
                  decoration: const InputDecoration(labelText: 'Province'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the province.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _postalCode,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Postal code (optional)',
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set as default address'),
                  value: _isDefault,
                  onChanged: (value) => setState(() => _isDefault = value),
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
                      : Text(_isEditing ? 'Save changes' : 'Add address'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = _isEditing
        ? await widget.controller.updateAddress(
            id: widget.address!.id,
            label: _label.text,
            recipientName: _recipientName.text,
            phone: _phone.text,
            addressLine: _addressLine.text,
            barangay: _barangay.text,
            city: _city.text,
            province: _province.text,
            postalCode: _postalCode.text,
            isDefault: _isDefault,
          )
        : await widget.controller.createAddress(
            label: _label.text,
            recipientName: _recipientName.text,
            phone: _phone.text,
            addressLine: _addressLine.text,
            barangay: _barangay.text,
            city: _city.text,
            province: _province.text,
            postalCode: _postalCode.text,
            isDefault: _isDefault,
          );

    if (success && mounted) Navigator.of(context).pop();
  }
}
