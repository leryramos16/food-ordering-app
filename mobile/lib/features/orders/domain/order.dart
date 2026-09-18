import 'order_item.dart';

class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.isPreorder = false,
    this.requestedDate,
    this.requestedTime,
    this.fulfillmentType = 'delivery',
    this.contactName,
    this.contactPhone,
    required this.restaurantName,
    required this.recipientName,
    required this.recipientPhone,
    required this.addressLine,
    required this.barangay,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.notes,
    required this.placedAt,
    required this.items,
  });

  final int id;
  final String orderNumber;
  final String status;
  final bool isPreorder;
  final DateTime? requestedDate;

  /// 24-hour "HH:mm" string, e.g. "14:30" — kept as a plain string since
  /// it's a time-of-day with no associated date to reason about.
  final String? requestedTime;
  final String fulfillmentType;
  final String? contactName;
  final String? contactPhone;
  final String? restaurantName;
  final String recipientName;
  final String recipientPhone;

  /// Null for a pre-order being picked up — there's no delivery address.
  final String? addressLine;
  final String? barangay;
  final String? city;
  final String? province;
  final String? postalCode;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String? notes;
  final DateTime? placedAt;
  final List<OrderItem> items;

  bool get isPickup => fulfillmentType == 'pickup';

  /// The delivery address, fully assembled from whichever parts are
  /// present — barangay and postal code are optional on an address, and
  /// there's no address at all for a pickup order.
  String get fullAddress {
    final parts = [
      addressLine,
      barangay,
      city,
      province,
    ].where((part) => part != null && part.isNotEmpty).join(', ');

    return postalCode == null || postalCode!.isEmpty
        ? parts
        : '$parts $postalCode';
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final deliveryAddress = Map<String, dynamic>.from(
      json['delivery_address'] as Map,
    );
    final restaurant = json['restaurant'] as Map?;
    final items = json['items'] as List<dynamic>? ?? [];

    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      status: json['status'] as String,
      isPreorder: json['is_preorder'] as bool? ?? false,
      requestedDate: json['requested_date'] != null
          ? DateTime.tryParse(json['requested_date'] as String)
          : null,
      requestedTime: json['requested_time'] as String?,
      fulfillmentType: json['fulfillment_type'] as String? ?? 'delivery',
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      restaurantName: restaurant?['name'] as String?,
      recipientName: deliveryAddress['recipient_name'] as String,
      recipientPhone: deliveryAddress['phone'] as String,
      addressLine: deliveryAddress['address_line'] as String?,
      barangay: deliveryAddress['barangay'] as String?,
      city: deliveryAddress['city'] as String?,
      province: deliveryAddress['province'] as String?,
      postalCode: deliveryAddress['postal_code'] as String?,
      subtotal: double.parse(json['subtotal'].toString()),
      deliveryFee: double.parse(json['delivery_fee'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      notes: json['notes'] as String?,
      placedAt: json['placed_at'] != null
          ? DateTime.tryParse(json['placed_at'] as String)
          : null,
      items: items
          .map(
            (item) =>
                OrderItem.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }
}
