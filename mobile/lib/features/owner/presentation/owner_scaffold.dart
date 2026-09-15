import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';

/// The owner/business side of the app uses a distinct accent color from the
/// customer app so it reads as a different "mode" — a management dashboard,
/// not another storefront screen.
final ThemeData ownerThemeData = buildAppTheme(const Color(0xff00695c));

/// A [Scaffold] pre-wrapped in the owner theme. Every owner-facing screen
/// should use this instead of a bare [Scaffold] so the dashboard styling
/// stays consistent across the whole owner flow, including screens pushed
/// on top of it.
class OwnerScaffold extends StatelessWidget {
  const OwnerScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ownerThemeData,
      child: Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
