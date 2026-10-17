import 'package:url_launcher/url_launcher.dart';

import 'logger.dart';

/// Opens a provider's checkout page.
///
/// A thin wrapper so a test can replace it, and so nothing else in the app
/// has to know which plugin does the opening. Externally, not in a web view:
/// a card form inside the app looks exactly like a phishing screen, and a
/// bank's 3-D Secure step often refuses to run in one.
class CheckoutLauncher {
  const CheckoutLauncher._();

  /// Replaced in tests. Returns true when the page was handed to the browser.
  static Future<bool> Function(String url) opener = _open;

  static Future<bool> open(String url) => opener(url);

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
