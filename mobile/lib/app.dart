import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/token_storage.dart';
import 'features/addresses/data/address_service.dart';
import 'features/addresses/state/address_controller.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/state/auth_controller.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/restaurants/data/restaurant_service.dart';
import 'features/restaurants/state/restaurant_controller.dart';

class FoodOrderingEstApp extends StatefulWidget {
  const FoodOrderingEstApp({super.key});

  @override
  State<FoodOrderingEstApp> createState() => _FoodOrderingEstAppState();
}

class _FoodOrderingEstAppState extends State<FoodOrderingEstApp> {
  late final TokenStorage storage;
  late final ApiClient apiClient;

  late final AuthController authController;
  late final RestaurantService restaurantService;
  late final RestaurantController restaurantController;
  late final AddressController addressController;

  @override
  void initState() {
    super.initState();

    storage = TokenStorage();

    apiClient = ApiClient(storage);

    authController = AuthController(AuthService(apiClient, storage))
      ..restoreSession();

    restaurantService = RestaurantService(apiClient);
    restaurantController = RestaurantController(restaurantService);

    addressController = AddressController(AddressService(apiClient));
  }

  @override
  void dispose() {
    authController.dispose();
    restaurantController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffe85d04)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: AnimatedBuilder(
        animation: authController,
        builder: (context, _) {
          if (authController.isCheckingSession) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return authController.isAuthenticated
              ? HomeScreen(
                  authController: authController,
                  restaurantController: restaurantController,
                  restaurantService: restaurantService,
                  addressController: addressController,
                )
              : LoginScreen(authController: authController);
        },
      ),
    );
  }
}
