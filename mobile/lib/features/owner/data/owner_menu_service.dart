import '../../../core/api_client.dart';
import '../../restaurants/domain/category.dart';

class OwnerMenuService {
  OwnerMenuService(this._api);

  final ApiClient _api;

  Future<List<Category>> getCategories() async {
    final response = await _api.get('/owner/categories', authenticated: true);

    final data = response['data'] as List<dynamic>;

    return data
        .map(
          (item) => Category.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<void> createCategory({
    required String name,
    required int sortOrder,
    required bool isActive,
  }) async {
    await _api.post(
      '/owner/categories',
      authenticated: true,
      body: {
        'name': name.trim(),
        'sort_order': sortOrder,
        'is_active': isActive,
      },
    );
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    required int sortOrder,
    required bool isActive,
  }) async {
    await _api.put(
      '/owner/categories/$id',
      authenticated: true,
      body: {
        'name': name.trim(),
        'sort_order': sortOrder,
        'is_active': isActive,
      },
    );
  }

  Future<void> deleteCategory(int id) {
    return _api.delete('/owner/categories/$id', authenticated: true);
  }

  Future<void> createMenuItem({
    required int categoryId,
    required String name,
    String? description,
    required double price,
    required bool isAvailable,
    int? preparationTimeMinutes,
  }) async {
    await _api.post(
      '/owner/categories/$categoryId/menu-items',
      authenticated: true,
      body: _menuItemBody(
        name: name,
        description: description,
        price: price,
        isAvailable: isAvailable,
        preparationTimeMinutes: preparationTimeMinutes,
      ),
    );
  }

  Future<void> updateMenuItem({
    required int id,
    required String name,
    String? description,
    required double price,
    required bool isAvailable,
    int? preparationTimeMinutes,
  }) async {
    await _api.put(
      '/owner/menu-items/$id',
      authenticated: true,
      body: _menuItemBody(
        name: name,
        description: description,
        price: price,
        isAvailable: isAvailable,
        preparationTimeMinutes: preparationTimeMinutes,
      ),
    );
  }

  Future<void> deleteMenuItem(int id) {
    return _api.delete('/owner/menu-items/$id', authenticated: true);
  }

  Future<void> uploadMenuItemImage(int id, String filePath) {
    return _api.uploadFile(
      '/owner/menu-items/$id/image',
      fieldName: 'image',
      filePath: filePath,
    );
  }

  Map<String, dynamic> _menuItemBody({
    required String name,
    String? description,
    required double price,
    required bool isAvailable,
    int? preparationTimeMinutes,
  }) {
    return {
      'name': name.trim(),
      'description': description?.trim().isEmpty == true
          ? null
          : description?.trim(),
      'price': price,
      'is_available': isAvailable,
      'preparation_time_minutes': preparationTimeMinutes,
    };
  }
}
