import 'package:flutter/material.dart';

import '../../cart/presentation/cart_icon_button.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../cart/state/cart_controller.dart';
import '../data/restaurant_service.dart';
import '../domain/category.dart';
import '../domain/menu_item.dart';
import '../domain/restaurant.dart';
import '../state/restaurant_menu_controller.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    required this.service,
    required this.cartController,
  });

  final int restaurantId;
  final String restaurantName;
  final RestaurantService service;
  final CartController cartController;

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
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
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.restaurant == null) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.restaurantName)),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (_controller.errorMessage != null &&
              _controller.restaurant == null) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.restaurantName)),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _controller.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () =>
                            _controller.loadMenu(widget.restaurantId),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final restaurant = _controller.restaurant!;
          final categories = restaurant.categories;

          if (categories.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: Text(restaurant.name)),
              body: const Center(child: Text('No menu items yet.')),
            );
          }

          return DefaultTabController(
            length: categories.length,
            child: RefreshIndicator(
              onRefresh: () => _controller.loadMenu(widget.restaurantId),
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 200,
                    actions: [
                      CartIconButton(controller: widget.cartController),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: _RestaurantBanner(restaurant: restaurant),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _RestaurantInfoBar(restaurant: restaurant),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _CategoryTabBarDelegate(
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: [
                          for (final category in categories)
                            Tab(text: category.name),
                        ],
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  children: [
                    for (final category in categories)
                      _CategoryMenuGrid(
                        category: category,
                        restaurant: restaurant,
                        cartController: widget.cartController,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: widget.cartController,
        builder: (context, _) {
          if (widget.cartController.isEmpty) return const SizedBox.shrink();
          return _ViewCartBar(cartController: widget.cartController);
        },
      ),
    );
  }
}

class _ViewCartBar extends StatelessWidget {
  const _ViewCartBar({required this.cartController});

  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CartScreen(controller: cartController),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: colorScheme.onPrimary),
                  const SizedBox(width: 10),
                  Text(
                    '${cartController.totalItems} item${cartController.totalItems == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'View cart  •  ₱${cartController.subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RestaurantBanner extends StatelessWidget {
  const _RestaurantBanner({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageUrl = restaurant.imageUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, _, _) => _gradient(colorScheme),
          )
        else
          _gradient(colorScheme),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.05),
                Colors.black.withValues(alpha: 0.65),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 14,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: restaurant.isOpen
                      ? Colors.green.shade600
                      : Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  restaurant.isOpen ? 'Open' : 'Closed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gradient(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        ),
      ),
      child: Icon(
        Icons.restaurant_outlined,
        size: 56,
        color: colorScheme.onPrimary.withValues(alpha: 0.5),
      ),
    );
  }
}

class _RestaurantInfoBar extends StatelessWidget {
  const _RestaurantInfoBar({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (restaurant.description != null) ...[
            Text(
              restaurant.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  restaurant.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _pill(
                context,
                Icons.delivery_dining_outlined,
                '₱${restaurant.deliveryFee.toStringAsFixed(2)} delivery',
              ),
              const SizedBox(width: 8),
              _pill(
                context,
                Icons.shopping_bag_outlined,
                'Min ₱${restaurant.minimumOrder.toStringAsFixed(2)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTabBarDelegate extends SliverPersistentHeaderDelegate {
  _CategoryTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _CategoryTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}

class _CategoryMenuGrid extends StatelessWidget {
  const _CategoryMenuGrid({
    required this.category,
    required this.restaurant,
    required this.cartController,
  });

  final Category category;
  final Restaurant restaurant;
  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    if (category.items.isEmpty) {
      return const Center(child: Text('No items in this category yet.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: category.items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) => _MenuItemTile(
        item: category.items[index],
        restaurant: restaurant,
        cartController: cartController,
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.item,
    required this.restaurant,
    required this.cartController,
  });

  final MenuItem item;
  final Restaurant restaurant;
  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: item.isAvailable ? 1 : 0.5,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _itemImage(colorScheme),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: _AddButton(
                      enabled: item.isAvailable,
                      item: item,
                      restaurant: restaurant,
                      cartController: cartController,
                    ),
                  ),
                  if (!item.isAvailable)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Unavailable',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '₱${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemImage(ColorScheme colorScheme) {
    final imageUrl = item.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.fastfood_outlined,
          size: 32,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, _, _) => Container(
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.fastfood_outlined,
          size: 32,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.enabled,
    required this.item,
    required this.restaurant,
    required this.cartController,
  });

  final bool enabled;
  final MenuItem item;
  final Restaurant restaurant;
  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: enabled
          ? colorScheme.primary
          : colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? () => _handleTap(context) : null,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.add,
            size: 18,
            color: enabled
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    if (cartController.belongsToDifferentRestaurant(restaurant.id)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Start a new cart?'),
          content: Text(
            'Your cart has items from ${cartController.restaurantName}. '
            'Adding from ${restaurant.name} will clear it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Start new cart'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
      cartController.clear();
    }

    cartController.addItem(
      item,
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      deliveryFee: restaurant.deliveryFee,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${item.name} added to cart')));
    }
  }
}
