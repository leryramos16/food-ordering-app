import 'package:flutter_test/flutter_test.dart';
import 'package:food_ordering_mobile/features/auth/domain/app_user.dart';

void main() {
  test('AppUser parses the Laravel response', () {
    final user = AppUser.fromJson({
      'id': 7,
      'name': 'Ana Cruz',
      'email': 'ana@example.com',
      'phone': null,
      'role': 'customer',
    });

    expect(user.id, 7);
    expect(user.email, 'ana@example.com');
    expect(user.role, 'customer');
  });
}
