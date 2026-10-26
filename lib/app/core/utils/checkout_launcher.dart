import 'package:url_launcher/url_launcher.dart';

import '../../data/models/checkout.dart';
import '../../modules/user/checkout/checkout_webview_screen.dart';
import '../../routes/app_routes.dart';
import 'logger.dart';
import 'package:get/get.dart';

/// Opens a provider's checkout page.
///
/// In a web view, inside the app. The system browser was the earlier
/// choice, on the reasoning that a card form inside an app looks like a
/// phishing screen and that 3-D Secure often refuses to run in one -- both
/// true, and both outweighed by what actually happened: the app went to the
/// background mid-payment, the payer was left on a Bachs page with no way
/// back, and the receipt screen was never reached.
///
/// The view is plain chrome with a close button, loads one URL and reads
/// nothing. If it cannot load the page at all, [present] still falls back
/// to the browser rather than stranding anybody.
class CheckoutLauncher {
  const CheckoutLauncher._();

  /// Replaced in tests. Returns true when the page was handed to the browser.
  static Future<bool> Function(String url) opener = _open;

  static Future<bool> open(String url) => opener(url);

  /// Replaced in tests, which have no navigator to push a web view onto.
  static Future<CheckoutOutcome> Function(Checkout checkout, String title)
      presenter = _present;

  /// Shows checkout and waits for it to close.
  ///
  /// The outcome says how it ended, never whether money moved: the payer
  /// reaching the return page means the provider is finished with them, and
  /// only the server's webhook says a payment arrived.
  static Future<CheckoutOutcome> present(
    Checkout checkout, {
    String title = 'Payment',
  }) =>
      presenter(checkout, title);

  static Future<CheckoutOutcome> _present(
    Checkout checkout,
    String title,
  ) async {
    final outcome = await Get.toNamed<dynamic>(
      AppRoutes.checkoutWebView,
      arguments: <String, dynamic>{
        'url': checkout.checkoutUrl,
        'returnUrl': checkout.returnUrl,
        'title': title,
      },
    );

    if (outcome is CheckoutOutcome && outcome != CheckoutOutcome.failed) {
      return outcome;
    }

    // The web view could not load it -- an old Android System WebView, or a
    // provider page that refuses to frame. Better the browser than nothing.
    Log.e('checkout web view failed; falling back to the browser');
    final opened = await open(checkout.checkoutUrl);
    return opened ? CheckoutOutcome.returned : CheckoutOutcome.failed;
  }

  static Future<bool> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error, stack) {
      Log.e('could not open checkout', error: error, stackTrace: stack);
      return false;
    }
  }
}

/// Opens anything else the app hands to the phone — a studio's Instagram, a
/// tel: link, a map.
///
/// Separate from [CheckoutLauncher] only in name: the same one-line wrapper,
/// so a test can replace it and nothing else has to know which plugin does
/// the opening.
class ExternalLink {
  const ExternalLink._();

  /// Replaced in tests. True when the phone took it.
  static Future<bool> Function(String url) opener = _open;

  static Future<bool> open(String url) => opener(url);

  /// A studio's Instagram. Tries the app first and falls back to the web,
  /// because a handle with no Instagram installed should still open.
  static Future<bool> instagram(String handle) async {
    final name = handle.replaceAll('@', '').trim();
    if (name.isEmpty) return false;
    if (await opener('instagram://user?username=$name')) return true;
    return opener('https://instagram.com/$name');
  }

  /// Dials a number — or rather, offers to: the dialler opens with the
  /// number in it and the person presses call.
  static Future<bool> call(String number) {
    final digits = number.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return Future.value(false);
    return opener('tel:$digits');
  }

  static Future<bool> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error, stack) {
      Log.e('could not open $url', error: error, stackTrace: stack);
      return false;
    }
  }
}
