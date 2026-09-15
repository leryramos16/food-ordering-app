import 'package:flutter/material.dart';

import '../../restaurants/domain/category.dart';
import '../state/owner_menu_controller.dart';

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key, required this.controller, this.category});

  final OwnerMenuController controller;

  /// Null when adding a new category, non-null when editing an existing one.
  final Category? category;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.category?.name);
  late final _sortOrder = TextEditingController(
    text: (widget.category?.sortOrder ?? 0).toString(),
  );
  late bool _isActive = widget.category?.isActive ?? true;

  bool get _isEditing => widget.category != null;

  @override
  void dispose() {
    _name.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit category' : 'Add category'),
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
                  decoration: const InputDecoration(
                    labelText: 'Category name (e.g. Drinks)',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a name.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _sortOrder,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Sort order',
                    helperText: 'Lower numbers show first.',
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    return parsed == null || parsed < 0
                        ? 'Enter a valid number.'
                        : null;
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active (visible to customers)'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
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
                      : Text(_isEditing ? 'Save changes' : 'Add category'),
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
        ? await widget.controller.updateCategory(
            id: widget.category!.id,
            name: _name.text,
            sortOrder: int.parse(_sortOrder.text),
            isActive: _isActive,
          )
        : await widget.controller.createCategory(
            name: _name.text,
            sortOrder: int.parse(_sortOrder.text),
            isActive: _isActive,
          );

    if (success && mounted) Navigator.of(context).pop();
  }
}
