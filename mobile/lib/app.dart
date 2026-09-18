import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/app_theme.dart';
import 'core/token_storage.dart';
import 'features/addresses/data/address_service.dart';
import 'features/addresses/state/address_controller.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/state/auth_controller.dart';
import 'features/cart/state/cart_controller.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/owner/data/owner_menu_service.dart';
import 'features/owner/data/owner_restaurant_service.dart';
import 'features/owner/presentation/owner_home_screen.dart';
import 'features/owner/state/owner_menu_controller.dart';
import 'features/owner/state/owner_restaurant_controller.dart';
import 'features/orders/data/order_service.dart';
import 'features/orders/data/owner_order_service.dart';
import 'features/orders/data/payment_service.dart';
import 'features/orders/state/checkout_controller.dart';
import 'features/orders/state/owner_order_controller.dart';
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
  late final OwnerRestaurantController ownerRestaurantController;
  late final OwnerMenuController ownerMenuController;
  late final CartController cartController;
  late final CheckoutController checkoutController;
  late final OwnerOrderController ownerOrderController;

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

    ownerRestaurantController = OwnerRestaurantController(
      OwnerRestaurantService(apiClient),
    );

    ownerMenuController = OwnerMenuController(OwnerMenuService(apiClient));

    cartController = CartController();

    checkoutController = CheckoutController(
      OrderService(apiClient),
      PaymentService(apiClient),
    );

    ownerOrderController = OwnerOrderController(OwnerOrderService(apiClient));
  }

  @override
  void dispose() {
    authController.dispose();
    restaurantController.dispose();
    addressController.dispose();
    ownerRestaurantController.dispose();
    ownerMenuController.dispose();
    cartController.dispose();
    checkoutController.dispose();
    ownerOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(const Color(0xffe85d04)),
      home: AnimatedBuilder(
        animation: authController,
        builder: (context, _) {
          if (authController.isCheckingSession) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!authController.isAuthenticated) {
            return LoginScreen(authController: authController);
          }

          return authController.user?.role == 'restaurant_owner'
              ? OwnerHomeScreen(
                  authController: authController,
                  restaurantController: ownerRestaurantController,
                  menuController: ownerMenuController,
                  orderController: ownerOrderController,
                )
              : HomeScreen(
                  authController: authController,
                  restaurantController: restaurantController,
                  restaurantService: restaurantService,
                  addressController: addressController,
                  cartController: cartController,
                  checkoutController: checkoutController,
                );
        },
      ),
    );
  }
}
