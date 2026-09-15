import 'category.dart';

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.phone,
    required this.address,
    required this.deliveryFee,
    required this.minimumOrder,
    required this.imageUrl,
    required this.isOpen,
    this.categories = const [],
  });

  final int id;
  final String name;
  final String? description;
  final String? phone;
  final String address;
  final double deliveryFee;
  final double minimumOrder;
  final String? imageUrl;
  final bool isOpen;
  final List<Category> categories;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final categories = json['categories'] as List<dynamic>? ?? [];

    return Restaurant(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String,
      deliveryFee: double.parse(json['delivery_fee'].toString()),
      minimumOrder: double.parse(json['minimum_order'].toString()),
      imageUrl: json['image_url'] as String?,
      isOpen: json['is_open'] as bool,
      categories: categories
          .map(
            (item) =>
                Category.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }
}
