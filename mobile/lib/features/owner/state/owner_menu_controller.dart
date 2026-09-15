import 'package:flutter/foundation.dart' hide Category;

import '../../restaurants/domain/category.dart';
import '../data/owner_menu_service.dart';

class OwnerMenuController extends ChangeNotifier {
  OwnerMenuController(this._service);

  final OwnerMenuService _service;

  List<Category> categories = [];

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> loadCategories() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      categories = await _service.getCategories();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory({
    required String name,
    required int sortOrder,
    required bool isActive,
  }) {
    return _mutate(
      () => _service.createCategory(
        name: name,
        sortOrder: sortOrder,
        isActive: isActive,
      ),
    );
  }

  Future<bool> updateCategory({
    required int id,
    required String name,
    required int sortOrder,
    required bool isActive,
  }) {
    return _mutate(
      () => _service.updateCategory(
        id: id,
        name: name,
        sortOrder: sortOrder,
        isActive: isActive,
      ),
    );
  }

  Future<bool> deleteCategory(int id) {
    return _mutate(() => _service.deleteCategory(id));
  }

  Future<bool> createMenuItem({
    required int categoryId,
    required String name,
    String? description,
    required double price,
    required bool isAvailable,
    int? preparationTimeMinutes,
  }) {
    return _mutate(
      () => _service.createMenuItem(
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        isAvailable: isAvailable,
        preparationTimeMinutes: preparationTimeMinutes,
      ),
    );
  }

  Future<bool> updateMenuItem({
    required int id,
    required String name,
    String? description,
    required double price,
    required bool isAvailable,
    int? preparationTimeMinutes,
  }) {
    return _mutate(
      () => _service.updateMenuItem(
        id: id,
        name: name,
        description: description,
        price: price,
        isAvailable: isAvailable,
        preparationTimeMinutes: preparationTimeMinutes,
      ),
    );
  }

  Future<bool> deleteMenuItem(int id) {
    return _mutate(() => _service.deleteMenuItem(id));
  }

  Future<bool> _mutate(Future<void> Function() action) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      categories = await _service.getCategories();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
