import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/app_export.dart';

/// What the checkout web view hands back when it closes.
enum CheckoutOutcome {
  /// The provider sent the payer to the return page. That page means the
  /// flow finished, not that money moved -- only the webhook says that --
  /// so the caller still asks the server.
  returned,

  /// Closed by the payer, with the X or the back gesture.
  abandoned,

  /// The page would not load at all.
  failed,
}

/// Bachs checkout, inside the app.
///
/// The payer used to be handed to the system browser. That backgrounds the
/// app mid-payment and leaves them on a Bachs page with no way back, so the
/// receipt screen was usually never reached and the booking looked unpaid.
///
/// Two things this deliberately does not do: it does not read the page, and
/// it does not decide that a payment succeeded. Reaching the return URL only
/// closes the view; the server is still the only thing that says money
/// arrived, and it learns that by webhook.
class CheckoutWebViewScreen extends StatefulWidget {
  const CheckoutWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.returnUrl,
    this.title = 'Payment',
  });

  final String checkoutUrl;

  /// The page the provider redirects to when it is done. Empty disables the
  /// watch, and then only the close button ends the flow -- which is still
  /// better than the browser, because the app is never left.
  final String returnUrl;

  final String title;

  @override
  State<CheckoutWebViewScreen> createState() => _CheckoutWebViewScreenState();
}

class _CheckoutWebViewScreenState extends State<CheckoutWebViewScreen> {
  late final WebViewController _web;

  final RxBool _loading = true.obs;

  /// So the view cannot pop twice -- the redirect fires on both the
  /// navigation request and the page finishing.
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (_isReturn(request.url)) {
              _finish(CheckoutOutcome.returned);
              // Stopped here: the return page is the site's own, and there
              // is nothing on it the payer needs to see inside the app.
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) => _loading.value = true,
          onPageFinished: (url) {
            _loading.value = false;
            if (_isReturn(url)) _finish(CheckoutOutcome.returned);
          },
          onWebResourceError: (error) {
            // Only the main document failing is worth acting on; a missing
            // image or a blocked tracker on a payment page is not.
            if (error.isForMainFrame ?? true) {
              Log.e('checkout page failed: ${error.description}');
              _finish(CheckoutOutcome.failed);
            }
          },
        ),
      );

    final uri = Uri.tryParse(widget.checkoutUrl);
    if (uri == null) {
      _finish(CheckoutOutcome.failed);
    } else {
      _web.loadRequest(uri);
    }
  }

  /// Whether a URL is the return page.
  ///
  /// Compared on host and path, ignoring the query: the provider appends its
  /// own parameters, so an exact match would never fire.
  bool _isReturn(String url) {
    if (widget.returnUrl.isEmpty) return false;
    final target = Uri.tryParse(widget.returnUrl);
    final here = Uri.tryParse(url);
    if (target == null || here == null) return false;
    if (target.host.isEmpty || here.host != target.host) return false;
    final wanted = target.path.replaceAll(RegExp(r'/+$'), '');
    final got = here.path.replaceAll(RegExp(r'/+$'), '');
    return wanted.isEmpty ? true : got == wanted || got.startsWith('$wanted/');
  }

  void _finish(CheckoutOutcome outcome) {
    if (_done || !mounted) return;
    _done = true;
    Get.back<CheckoutOutcome>(result: outcome);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Leaving by the back gesture is abandoning, and the caller has to be
      // told which it was so it does not sit polling for a payment nobody
      // is making.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish(CheckoutOutcome.abandoned);
      },
      child: Scaffold(
        backgroundColor: appTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24.h, 16.v, 24.h, 8.v),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => _finish(CheckoutOutcome.abandoned),
                      child: Icon(
                        Icons.close,
                        size: 22.h,
                        color: appTheme.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.appBarTitle
                            .copyWith(color: appTheme.brandDeep),
                      ),
                    ),
                    // Balances the close button so the title sits centred.
                    SizedBox(width: 22.h),
                  ],
                ),
              ),
              Obx(
                () => _loading.value
                    ? SizedBox(
                        height: 2.v,
                        child: LinearProgressIndicator(
                          minHeight: 2.v,
                          backgroundColor: appTheme.cardRim,
                        ),
                      )
                    : SizedBox(height: 2.v),
              ),
              Expanded(child: WebViewWidget(controller: _web)),
            ],
          ),
        ),
      ),
    );
  }
}
