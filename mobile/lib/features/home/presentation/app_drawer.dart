import 'package:flutter/material.dart';

import '../../addresses/presentation/address_list_screen.dart';
import '../../addresses/state/address_controller.dart';
import '../../auth/state/auth_controller.dart';
import '../../orders/presentation/my_orders_screen.dart';
import '../../orders/state/my_orders_controller.dart';

/// The customer app's navigation sidebar — everything that isn't part of
/// the moment-to-moment browsing/ordering flow (orders, addresses, account)
/// lives here instead of crowding the home app bar. Cart stays outside,
/// in the app bar, since it's the one action used constantly while
/// browsing.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.authController,
    required this.addressController,
    required this.myOrdersController,
  });

  final AuthController authController;
  final AddressController addressController;
  final MyOrdersController myOrdersController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = authController.user;
    final initial = (user?.name.isNotEmpty == true ? user!.name[0] : '?')
        .toUpperCase();

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary, colorScheme.primaryContainer],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _DrawerTile(
              icon: Icons.receipt_long_outlined,
              label: 'My orders',
              onTap: () => _navigate(
                context,
                MyOrdersScreen(controller: myOrdersController),
              ),
            ),
            _DrawerTile(
              icon: Icons.location_on_outlined,
              label: 'My addresses',
              onTap: () => _navigate(
                context,
                AddressListScreen(controller: addressController),
              ),
            ),
            const Spacer(),
            const Divider(height: 1),
            _DrawerTile(
              icon: Icons.logout,
              label: 'Log out',
              color: colorScheme.error,
              onTap: () {
                Navigator.of(context).pop();
                authController.logout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tint = color ?? colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: (color ?? colorScheme.primary).withValues(
                    alpha: 0.12,
                  ),
                  child: Icon(icon, size: 18, color: color ?? colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontWeight: FontWeight.w600, color: tint),
                  ),
                ),
                if (color == null)
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
