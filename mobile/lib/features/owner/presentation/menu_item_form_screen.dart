import 'package:flutter/material.dart';

import '../../restaurants/domain/menu_item.dart';
import '../state/owner_menu_controller.dart';
import 'owner_photo_picker.dart';
import 'owner_scaffold.dart';

class MenuItemFormScreen extends StatefulWidget {
  const MenuItemFormScreen({
    super.key,
    required this.controller,
    required this.categoryId,
    this.menuItem,
  });

  final OwnerMenuController controller;

  /// The category this item belongs to (or will be added to).
  final int categoryId;

  /// Null when adding a new item, non-null when editing an existing one.
  final MenuItem? menuItem;

  @override
  State<MenuItemFormScreen> createState() => _MenuItemFormScreenState();
}

class _MenuItemFormScreenState extends State<MenuItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.menuItem?.name);
  late final _description = TextEditingController(
    text: widget.menuItem?.description,
  );
  late final _price = TextEditingController(
    text: widget.menuItem?.price.toStringAsFixed(2),
  );
  late final _preparationTime = TextEditingController(
    text: widget.menuItem?.preparationTimeMinutes?.toString(),
  );
  late final _preorderLeadDays = TextEditingController(
    text: widget.menuItem?.preorderLeadDays?.toString(),
  );
  late bool _isAvailable = widget.menuItem?.isAvailable ?? true;
  late bool _isPreorder = widget.menuItem?.isPreorder ?? false;

  bool get _isEditing => widget.menuItem != null;

  /// The item's live data from the controller (so an uploaded photo shows
  /// up immediately), falling back to the snapshot this screen opened with.
  MenuItem? get _currentItem {
    if (widget.menuItem == null) return null;

    for (final category in widget.controller.categories) {
      for (final item in category.items) {
        if (item.id == widget.menuItem!.id) return item;
      }
    }

    return widget.menuItem;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _preparationTime.dispose();
    _preorderLeadDays.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => OwnerScaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit menu item' : 'Add menu item'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isEditing) ...[
                  OwnerPhotoPicker(
                    imageUrl: _currentItem?.imageUrl,
                    isUploading: widget.controller.isSubmitting,
                    placeholderIcon: Icons.fastfood_outlined,
                    onPicked: (path) => widget.controller.uploadMenuItemImage(
                      widget.menuItem!.id,
                      path,
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  Text(
                    'You can add a photo once the item is created.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Item name'),
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
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    return parsed == null || parsed < 0
                        ? 'Enter a valid price.'
                        : null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _preparationTime,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Preparation time in minutes (optional)',
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Available'),
                  value: _isAvailable,
                  onChanged: (value) => setState(() => _isAvailable = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Pre-order / advance order only'),
                  subtitle: const Text(
                    'e.g. a custom cake that needs advance notice',
                  ),
                  value: _isPreorder,
                  onChanged: (value) => setState(() => _isPreorder = value),
                ),
                if (_isPreorder) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _preorderLeadDays,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Days of advance notice needed',
                      hintText: 'e.g. 2',
                    ),
                    validator: (value) {
                      if (!_isPreorder) return null;
                      final parsed = int.tryParse(value ?? '');
                      return parsed == null || parsed < 1
                          ? 'Enter how many days notice this needs.'
                          : null;
                    },
                  ),
                ],
                if (widget.controller.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.controller.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
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
                      : Text(_isEditing ? 'Save changes' : 'Add item'),
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

    final preparationTime = _preparationTime.text.trim().isEmpty
        ? null
        : int.tryParse(_preparationTime.text.trim());

    final preorderLeadDays = _isPreorder
        ? int.tryParse(_preorderLeadDays.text.trim())
        : null;

    final success = _isEditing
        ? await widget.controller.updateMenuItem(
            id: widget.menuItem!.id,
            name: _name.text,
            description: _description.text,
            price: double.parse(_price.text),
            isAvailable: _isAvailable,
            preparationTimeMinutes: preparationTime,
            isPreorder: _isPreorder,
            preorderLeadDays: preorderLeadDays,
          )
        : await widget.controller.createMenuItem(
            categoryId: widget.categoryId,
            name: _name.text,
            description: _description.text,
            price: double.parse(_price.text),
            isAvailable: _isAvailable,
            preparationTimeMinutes: preparationTime,
            isPreorder: _isPreorder,
            preorderLeadDays: preorderLeadDays,
          );

    if (success && mounted) Navigator.of(context).pop();
  }
}
