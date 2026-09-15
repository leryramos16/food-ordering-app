import 'package:flutter/material.dart';

import '../data/restaurant_service.dart';
import '../state/restaurant_menu_controller.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    required this.service,
  });

  final int restaurantId;
  final String restaurantName;
  final RestaurantService service;

  @override
  State<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late final RestaurantMenuController _controller;

  @override
  void initState() {
    super.initState();

    _controller = RestaurantMenuController(widget.service);
    _controller.loadMenu(widget.restaurantId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.restaurantName)),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.restaurant == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null &&
              _controller.restaurant == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(_controller.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _controller.loadMenu(widget.restaurantId),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final restaurant = _controller.restaurant!;

          return RefreshIndicator(
            onRefresh: () => _controller.loadMenu(widget.restaurantId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Chip(label: Text(restaurant.isOpen ? 'Open' : 'Closed')),
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

                const SizedBox(height: 24),

                if (restaurant.categories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('No menu items yet.')),
                  ),

                for (final category in restaurant.categories) ...[
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),

                  for (final item in category.items)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: item.description != null
                            ? Text(item.description!)
                            : null,
                        trailing: Text(
                          '₱${item.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        enabled: item.isAvailable,
                        onTap: item.isAvailable
                            ? () {
                                // Next feature:
                                // Add to cart.
                              }
                            : null,
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
