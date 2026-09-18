import 'package:flutter/material.dart';

/// A small "Requested for `date`" pill shown wherever a pre-order's
/// scheduled date needs to be visible — order confirmation, order history,
/// and the owner's order list/detail. Optionally includes the requested
/// time and whether it's pickup or delivery, when known.
class PreorderBadge extends StatelessWidget {
  const PreorderBadge({
    super.key,
    required this.date,
    this.time,
    this.fulfillmentType,
  });

  final DateTime date;

  /// 24-hour "HH:mm" string, e.g. "14:30".
  final String? time;

  /// "pickup" or "delivery".
  final String? fulfillmentType;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String? get _friendlyTime {
    final value = time;
    if (value == null) return null;

    final parts = value.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';

    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final label = StringBuffer(
      'Requested for ${_months[date.month - 1]} ${date.day}, ${date.year}',
    );

    if (_friendlyTime != null) label.write(' at $_friendlyTime');
    if (fulfillmentType == 'pickup') label.write(' • Pickup');
    if (fulfillmentType == 'delivery') label.write(' • Delivery');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_outlined, size: 13, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label.toString(),
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
