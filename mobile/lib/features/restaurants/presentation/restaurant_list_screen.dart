import 'package:flutter/material.dart';

import '../state/restaurant_controller.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key, required this.controller});

  final RestaurantController controller;

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  @override
  void initState() {
    super.initState();

    widget.controller.loadRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;

        if (controller.isLoading && controller.restaurants.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null && controller.restaurants.isEmpty) {
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
                    onPressed: controller.loadRestaurants,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.restaurants.isEmpty) {
          return const Center(child: Text('No restaurants available.'));
        }

        return RefreshIndicator(
          onRefresh: controller.loadRestaurants,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.restaurants.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final restaurant = controller.restaurants[index];

              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    // Next feature:
                    // Open restaurant menu.
                  },
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
                              label: Text(
                                restaurant.isOpen ? 'Open' : 'Closed',
                              ),
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
                          '₱${restaurant.deliveryFee.toStringAsFixed(2)}',
                        ),

                        Text(
                          'Minimum order: '
                          '₱${restaurant.minimumOrder.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
