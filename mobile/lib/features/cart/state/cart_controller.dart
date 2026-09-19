import 'package:flutter/foundation.dart';

import '../../restaurants/domain/menu_item.dart';
import '../domain/cart_item.dart';

class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];

  int? restaurantId;
  String? restaurantName;
  double deliveryFee = 0;

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.lineTotal);

  double get total => subtotal + (isEmpty ? 0 : deliveryFee);

  /// The longest advance-notice requirement among any pre-order item
  /// currently in the cart. 0 means nothing here needs advance notice.
  int get requiredPreorderLeadDays {
    var maxDays = 0;

    for (final item in _items) {
      if (item.menuItem.isPreorder) {
        final days = item.menuItem.preorderLeadDays ?? 1;
        if (days > maxDays) maxDays = days;
      }
    }

    return maxDays;
  }

  bool get requiresPreorderDate => requiredPreorderLeadDays > 0;

  /// A cart can only hold items from one restaurant at a time. This tells
  /// the UI whether adding from [otherRestaurantId] would conflict with
  /// what's already in the cart, so it can ask the user first.
  bool belongsToDifferentRestaurant(int otherRestaurantId) {
    return restaurantId != null && restaurantId != otherRestaurantId;
  }

  /// A pre-order item needs its own scheduled delivery slot, so it can't
  /// share a cart with a regular "order now" item. This tells the UI
  /// whether adding an item with the given pre-order-ness would conflict
  /// with what's already in the cart.
  bool hasPreorderConflict(bool otherItemIsPreorder) {
    return _items.isNotEmpty && requiresPreorderDate != otherItemIsPreorder;
  }

  void addItem(
    MenuItem menuItem, {
    required int restaurantId,
    required String restaurantName,
    required double deliveryFee,
  }) {
    this.restaurantId = restaurantId;
    this.restaurantName = restaurantName;
    this.deliveryFee = deliveryFee;

    final index = _items.indexWhere(
      (cartItem) => cartItem.menuItem.id == menuItem.id,
    );

    if (index == -1) {
      _items.add(CartItem(menuItem: menuItem, quantity: 1));
    } else {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
    }

    notifyListeners();
  }

  void incrementQuantity(int menuItemId) {
    final index = _items.indexWhere(
      (cartItem) => cartItem.menuItem.id == menuItemId,
    );
    if (index == -1) return;

    _items[index] = _items[index].copyWith(
      quantity: _items[index].quantity + 1,
    );
    notifyListeners();
  }

  void decrementQuantity(int menuItemId) {
    final index = _items.indexWhere(
      (cartItem) => cartItem.menuItem.id == menuItemId,
    );
    if (index == -1) return;

    final newQuantity = _items[index].quantity - 1;

    if (newQuantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
    }

    _clearIfEmpty();
    notifyListeners();
  }

  void removeItem(int menuItemId) {
    _items.removeWhere((cartItem) => cartItem.menuItem.id == menuItemId);
    _clearIfEmpty();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    restaurantId = null;
    restaurantName = null;
    deliveryFee = 0;
    notifyListeners();
  }

  void _clearIfEmpty() {
    if (_items.isEmpty) {
      restaurantId = null;
      restaurantName = null;
      deliveryFee = 0;
    }
  }
}
