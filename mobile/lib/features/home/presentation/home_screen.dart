import 'package:flutter/material.dart';

import '../../addresses/presentation/address_list_screen.dart';
import '../../addresses/state/address_controller.dart';
import '../../auth/state/auth_controller.dart';
import '../../cart/presentation/cart_icon_button.dart';
import '../../cart/state/cart_controller.dart';
import '../../restaurants/data/restaurant_service.dart';
import '../../restaurants/presentation/restaurant_list_screen.dart';
import '../../restaurants/state/restaurant_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.authController,
    required this.restaurantController,
    required this.restaurantService,
    required this.addressController,
    required this.cartController,
  });

  final AuthController authController;
  final RestaurantController restaurantController;
  final RestaurantService restaurantService;
  final AddressController addressController;
  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    final firstName = authController.user?.name.split(' ').first ?? '';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hi, $firstName 👋', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 2),
            Text(
              'What are you craving today?',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          CartIconButton(controller: cartController),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    AddressListScreen(controller: addressController),
              ),
            ),
            icon: const Icon(Icons.location_on_outlined),
            tooltip: 'My addresses',
          ),
          IconButton(
            onPressed: authController.isSubmitting
                ? null
                : authController.logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
          ),
        ],
      ),
      body: RestaurantListScreen(
        controller: restaurantController,
        service: restaurantService,
        cartController: cartController,
      ),
    );
  }
}
