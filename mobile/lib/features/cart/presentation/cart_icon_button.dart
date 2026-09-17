import 'package:flutter/material.dart';

import '../../addresses/state/address_controller.dart';
import '../../orders/state/checkout_controller.dart';
import '../state/cart_controller.dart';
import 'cart_screen.dart';

class CartIconButton extends StatelessWidget {
  const CartIconButton({
    super.key,
    required this.controller,
    required this.addressController,
    required this.checkoutController,
  });

  final CartController controller;
  final AddressController addressController;
  final CheckoutController checkoutController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CartScreen(
                  controller: controller,
                  addressController: addressController,
                  checkoutController: checkoutController,
                ),
              ),
            ),
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Cart',
          ),
          if (controller.totalItems > 0)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${controller.totalItems}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
