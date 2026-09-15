import 'package:flutter/material.dart';

import '../../auth/state/auth_controller.dart';
import '../../restaurants/data/restaurant_service.dart';
import '../../restaurants/presentation/restaurant_list_screen.dart';
import '../../restaurants/state/restaurant_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.authController,
    required this.restaurantController,
    required this.restaurantService,
  });

  final AuthController authController;
  final RestaurantController restaurantController;
  final RestaurantService restaurantService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${authController.user?.name ?? ''}'),
        actions: [
          IconButton(
            onPressed: authController.isSubmitting
                ? null
                : authController.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RestaurantListScreen(
        controller: restaurantController,
        service: restaurantService,
      ),
    );
  }
}
