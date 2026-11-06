import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../core/utils/checkout_launcher.dart';
import '../../checkout/checkout_webview_screen.dart' show CheckoutOutcome;
import '../../../../data/models/passport_tier.dart';
import '../../../../data/repositories/billing_repository.dart';

/// Choosing and paying for a Passport tier — Figma `4958:26661`.
///
/// The Plans card used to collect an email for a waitlist. It sells now, so
/// this picks a tier and starts a checkout for it, the same way the trial
/// and a session booking do: the server opens the payment with Bachs and
/// hands back a URL, and the webhook — not the browser closing — is what
/// decides whether it was paid.
class PassportController extends BaseController {
  PassportController(this._billing);

  final BillingRepository _billing;

  List<PassportTier> get tiers => PassportTier.all;

  /// Which tier's checkout is in flight, so only its own button spins.
  final Rxn<PassportTier> chosen = Rxn<PassportTier>();

  /// Separate from [isLoading]: guard sets that, and a spinner that comes
  /// and goes with every guarded call flickers on a screen that does one
  /// thing.
  final RxBool busy = false.obs;

  Future<void> choose(PassportTier tier) async {
    if (busy.value) return;
    busy.value = true;
    chosen.value = tier;

    final checkout = await guard(
      () => _billing.startMembership(
        planKey: tier.key,
        cadence: 'monthly',
        // A pack bought outright. There is no week to try: the allowance
        // starts the moment it is paid for.
        trial: false,
      ),
      setLoading: false,
    );
    busy.value = false;
    if (checkout == null) {
      chosen.value = null;
      return;
    }

    if (checkout.checkoutUrl.isEmpty) {
      // No product behind this tier at Bachs yet. Said plainly rather than
      // dropping the user on a success screen for a payment that never
      // happened.
      chosen.value = null;
      AppFeedback.info('Checkout is not connected yet — nothing was charged.');
      return;
    }

    final outcome = await CheckoutLauncher.present(
      checkout,
      title: tier.name,
    );
    if (outcome == CheckoutOutcome.failed) {
      chosen.value = null;
      AppFeedback.error('Could not open the payment page.');
      return;
    }

    // The webhook decides, not the browser closing — the same rule the
    // booking flow follows. Somebody who closed the view may well have paid
    // first, so that case is given a couple of looks rather than the full
    // wait; nobody who walked away is left watching a spinner for a minute.
    busy.value = true;
    final paid = await _waitForPayment(
      checkout.reference,
      attempts: outcome == CheckoutOutcome.abandoned ? 2 : 12,
    );
    busy.value = false;
    chosen.value = null;

    if (!paid) {
      AppFeedback.info(
        outcome == CheckoutOutcome.abandoned
            ? 'That payment was not completed. Your tier is still here when '
                'you want it.'
            : 'We have not seen the payment yet. Your pass starts as soon '
                'as it lands.',
      );
      return;
    }

    Get.toNamed(AppRoutes.passportSuccess, arguments: tier);
  }

  /// Ask the server, a few times, whether the webhook has arrived.
  ///
  /// Bounded for the same reason the booking flow bounds it: a payment that
  /// has not landed in a minute has probably been abandoned.
  Future<bool> _waitForPayment(String reference, {int attempts = 12}) async {
    for (var attempt = 0; attempt < attempts; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 5));
      final status = await guard(
        () => _billing.paymentStatus(reference),
        showFeedback: false,
        setLoading: false,
      );
      if (status == 'paid') return true;
      if (status == 'failed') return false;
    }
    return false;
  }
}
