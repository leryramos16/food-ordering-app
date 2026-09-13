import 'package:flutter/material.dart';

import '../../auth/state/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.authController, super.key});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final user = authController.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Ordering'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: authController.isSubmitting
                ? null
                : authController.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                child: Text(user.name.substring(0, 1).toUpperCase()),
              ),
              const SizedBox(height: 16),
              Text(
                'Hello, ${user.name}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(user.email),
              const SizedBox(height: 28),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'You are signed in. This is the protected home screen where restaurant browsing and the cart can be added next.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
