class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.preparationTimeMinutes,
    this.isPreorder = false,
    this.preorderLeadDays,
  });

  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int? preparationTimeMinutes;
  final bool isPreorder;
  final int? preorderLeadDays;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool,
      preparationTimeMinutes: json['preparation_time_minutes'] as int?,
      isPreorder: json['is_preorder'] as bool? ?? false,
      preorderLeadDays: json['preorder_lead_days'] as int?,
    );
  }
}
