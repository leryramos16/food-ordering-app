import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/token_storage.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/state/auth_controller.dart';
import 'features/home/presentation/home_screen.dart';

class FoodOrderingEstApp extends StatefulWidget {
  const FoodOrderingEstApp({super.key});

  @override
  State<FoodOrderingEstApp> createState() => _FoodOrderingEstAppState();
}

class _FoodOrderingEstAppState extends State<FoodOrderingEstApp> {
  late final AuthController authController;

  @override
  void initState() {
    super.initState();
    final storage = TokenStorage();
    final apiClient = ApiClient(storage);
    authController = AuthController(AuthService(apiClient, storage))
      ..restoreSession();
  }

  @override
  void dispose() {
    authController.dispose();
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
              ? HomeScreen(authController: authController)
              : LoginScreen(authController: authController);
        },
      ),
    );
  }
}
