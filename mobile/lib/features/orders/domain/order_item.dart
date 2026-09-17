class OrderItem {
  const OrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  final int id;
  final int menuItemId;
  final String name;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      menuItemId: json['menu_item_id'] as int,
      name: json['name'] as String,
      unitPrice: double.parse(json['unit_price'].toString()),
      quantity: json['quantity'] as int,
      lineTotal: double.parse(json['line_total'].toString()),
    );
  }
}
