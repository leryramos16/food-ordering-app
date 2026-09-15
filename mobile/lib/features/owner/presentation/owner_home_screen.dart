import 'package:flutter/material.dart';

import '../../auth/state/auth_controller.dart';
import '../state/owner_menu_controller.dart';
import '../state/owner_restaurant_controller.dart';
import 'owner_menu_screen.dart';
import 'restaurant_form_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({
    super.key,
    required this.authController,
    required this.restaurantController,
    required this.menuController,
  });

  final AuthController authController;
  final OwnerRestaurantController restaurantController;
  final OwnerMenuController menuController;

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  @override
  void initState() {
    super.initState();

    widget.restaurantController.loadMyRestaurant();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${widget.authController.user?.name ?? ''}'),
        actions: [
          IconButton(
            onPressed: widget.authController.isSubmitting
                ? null
                : widget.authController.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.restaurantController,
        builder: (context, _) {
          final controller = widget.restaurantController;

          if (controller.isLoading && controller.restaurant == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null && controller.restaurant == null) {
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
                      onPressed: controller.loadMyRestaurant,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final restaurant = controller.restaurant;

          if (restaurant == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront_outlined, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      "You haven't set up your restaurant yet.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RestaurantFormScreen(
                            controller: widget.restaurantController,
                          ),
                        ),
                      ),
                      child: const Text('Create your restaurant'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadMyRestaurant,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Chip(
                              label: Text(restaurant.isOpen ? 'Open' : 'Closed'),
                            ),
                          ],
                        ),
                        if (restaurant.description != null) ...[
                          const SizedBox(height: 8),
                          Text(restaurant.description!),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text(restaurant.address)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Delivery fee: '
                          '₱${restaurant.deliveryFee.toStringAsFixed(2)}'
                          '   •   '
                          'Minimum order: '
                          '₱${restaurant.minimumOrder.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RestaurantFormScreen(
                        controller: widget.restaurantController,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit restaurant'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          OwnerMenuScreen(controller: widget.menuController),
                    ),
                  ),
                  icon: const Icon(Icons.restaurant_menu_outlined),
                  label: const Text('Manage menu'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
