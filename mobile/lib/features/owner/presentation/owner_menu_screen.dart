import 'package:flutter/material.dart';

import '../state/owner_menu_controller.dart';
import 'category_form_screen.dart';
import 'menu_item_form_screen.dart';
import 'owner_scaffold.dart';

class OwnerMenuScreen extends StatefulWidget {
  const OwnerMenuScreen({super.key, required this.controller});

  final OwnerMenuController controller;

  @override
  State<OwnerMenuScreen> createState() => _OwnerMenuScreenState();
}

class _OwnerMenuScreenState extends State<OwnerMenuScreen> {
  @override
  void initState() {
    super.initState();

    widget.controller.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return OwnerScaffold(
      appBar: AppBar(title: const Text('My menu')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryFormScreen(controller: widget.controller),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Category'),
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final controller = widget.controller;

          if (controller.isLoading && controller.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null && controller.categories.isEmpty) {
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
                      onPressed: controller.loadCategories,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.categories.isEmpty) {
            return const Center(
              child: Text('No categories yet. Tap + to add one.'),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadCategories,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final category in controller.categories)
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              if (!category.isActive)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Chip(
                                    label: Text('Inactive'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              IconButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CategoryFormScreen(
                                      controller: widget.controller,
                                      category: category,
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _confirmDeleteCategory(context, category.id),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          for (final item in category.items)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.name),
                              subtitle: Text(
                                item.isAvailable ? 'Available' : 'Unavailable',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('₱${item.price.toStringAsFixed(2)}'),
                                  IconButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => MenuItemFormScreen(
                                          controller: widget.controller,
                                          categoryId: category.id,
                                          menuItem: item,
                                        ),
                                      ),
                                    ),
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _confirmDeleteMenuItem(context, item.id),
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                  ),
                                ],
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MenuItemFormScreen(
                                    controller: widget.controller,
                                    categoryId: category.id,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Add item'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteCategory(BuildContext context, int categoryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete category'),
        content: const Text(
          'This also deletes every item in this category. Continue?',
        ),
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
      await widget.controller.deleteCategory(categoryId);
    }
  }

  Future<void> _confirmDeleteMenuItem(BuildContext context, int menuItemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item'),
        content: const Text('Are you sure you want to delete this item?'),
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
      await widget.controller.deleteMenuItem(menuItemId);
    }
  }
}
