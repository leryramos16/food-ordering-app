import 'package:flutter/material.dart';

import '../state/address_controller.dart';
import 'address_form_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key, required this.controller});

  final AddressController controller;

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();

    widget.controller.loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My addresses')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddressFormScreen(controller: widget.controller),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final controller = widget.controller;

          if (controller.isLoading && controller.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null && controller.addresses.isEmpty) {
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
                      onPressed: controller.loadAddresses,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.addresses.isEmpty) {
            return const Center(
              child: Text('No addresses yet. Tap + to add one.'),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadAddresses,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = controller.addresses[index];

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    title: Row(
                      children: [
                        Text(address.label),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          const Chip(
                            label: Text('Default'),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      '${address.recipientName} • ${address.phone}\n'
                      '${address.addressLine}, '
                      '${[
                        address.barangay,
                        address.city,
                        address.province,
                      ].where((part) => part != null && part.isNotEmpty).join(', ')}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddressFormScreen(
                                controller: widget.controller,
                                address: address,
                              ),
                            ),
                          );
                        } else if (value == 'delete') {
                          _confirmDelete(context, address.id);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int addressId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.controller.deleteAddress(addressId);
    }
  }
}
