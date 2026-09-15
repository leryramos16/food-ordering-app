import 'menu_item.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.items,
  });

  final int id;
  final String name;
  final int sortOrder;
  final List<MenuItem> items;

  factory Category.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? [];

    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int,
      items: items
          .map(
            (item) => MenuItem.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }
}
