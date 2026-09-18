import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Loads Dragonpay's hosted GCash payment page and watches for the browser
/// to land on our backend's "return" URL — that's Dragonpay's signal that
/// the customer finished (or cancelled) the payment attempt. The actual
/// payment_status update happens separately, server-to-server, when
/// Dragonpay calls our postback endpoint — this screen only decides when to
/// stop showing the WebView and hand control back to the app.
class DragonpayPaymentScreen extends StatefulWidget {
  const DragonpayPaymentScreen({super.key, required this.paymentUrl});

  final String paymentUrl;

  static const _returnUrlMarker = '/payments/dragonpay/return';

  @override
  State<DragonpayPaymentScreen> createState() => _DragonpayPaymentScreenState();
}

class _DragonpayPaymentScreenState extends State<DragonpayPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasReturned = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: _handleUrlChange,
          onProgress: (progress) {
            if (progress == 100 && mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleUrlChange(String url) {
    if (_hasReturned) return;
    if (!url.contains(DragonpayPaymentScreen._returnUrlMarker)) return;

    _hasReturned = true;

    // Let the return page render for a moment before closing, so the
    // customer sees a "thanks" screen rather than an instant pop.
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pay with GCash'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
