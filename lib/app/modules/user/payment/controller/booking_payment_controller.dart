import 'package:intl/intl.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../core/utils/checkout_launcher.dart';
import '../../../../data/models/booked_slot.dart';
import '../../../../data/models/coach.dart';
import '../../../../data/models/booked_session.dart';
import '../../../../data/models/session_offering.dart';
import '../../../../data/repositories/billing_repository.dart';

/// Backs the booking payment screen and its receipt — Figma "Therapist
/// booking payment" (`259:58862`), "Pilates booking paymet" (`259:58919`)
/// and "Yoga booking paymet" (`259:58941`).
///
/// The last two are pixel-identical; the therapist frame differs only in its
/// prices and in spelling the cancellation policy out. So one screen serves
/// all three, taking the [SessionOffering].
class BookingPaymentController extends BaseController {
  BookingPaymentController(this.offering, this._billing, {this.booked, this.session});

  final BillingRepository _billing;

  /// The session the server is holding, when the calendar made one. Null on
  /// the older entry points, which reach this screen without booking first.
  final BookedSession? session;

  final SessionOffering offering;

  /// When the session runs, chosen on the calendar before this screen. Null
  /// only on the older entry points that open payment without a time.
  final BookedSlot? booked;

  /// The frames draw Monthly Plan filled and Single Session outlined, which
  /// is the selected state — so Monthly is where the screen opens.
  final Rx<SessionPlan> plan = SessionPlan.monthly.obs;

  /// Whose session this is. The frames print the literal placeholder
  /// "[Expert Name]"; the matched coach is who actually goes there.
  /// The heading greets the expert by first name — "Ready for your session
  /// with Baraqhat" — which is what keeps it on one line.
  String get expertName => Coach.sample.name.split(' ').first;

  void select(SessionPlan value) => plan.value = value;

  int get amount => switch (plan.value) {
        SessionPlan.single => offering.single,
        SessionPlan.monthly => offering.monthly,
      };

  /// The frames print a bare figure — "25,000" — with no currency mark at
  /// all. A price on a payment screen that does not say what it is in is a
  /// hazard, so the naira sign is added here. It is this app's addition, not
  /// the design's.
  static String money(int naira) =>
      '₦${NumberFormat.decimalPattern('en').format(naira)}';


  /// On to "Confirm booking" — the Care Guarantee and the totals — which is
  /// where the payment is actually started.
  ///
  /// That screen was built and never reached: this used to jump straight to
  /// the receipt, so nobody ever saw what they were agreeing to. The chosen
  /// time travels along, since the confirmation at the end names it.
  void proceed() => Get.toNamed(
        AppRoutes.confirmBooking,
        arguments: booked ?? offering,
      );

  /// Start the payment: ask the server for a checkout and open it.
  ///
  /// Nothing here decides that money moved. The provider tells the server by
  /// webhook, the server marks the session confirmed, and this screen finds
  /// out by asking -- which is why it polls rather than trusting the browser
  /// coming back.
  Future<void> pay() async {
    final held = session;
    if (held == null) {
      // No session to pay for: an older entry point reached this screen
      // without the calendar. Send them to pick a time first.
      AppFeedback.info('Choose a time for your session first.');
      return;
    }
    if (isLoading.value) return;

    final checkout = await guard(() => _billing.paySession(held.id));
    if (checkout == null) return;

    if (checkout.checkoutUrl.isEmpty) {
      // The mock repository, or a server without payment keys. Said plainly
      // rather than pretending a charge went through.
      AppFeedback.info('Payments are not connected yet — nothing was charged.');
      return;
    }

    final opened = await CheckoutLauncher.open(checkout.checkoutUrl);
    if (!opened) {
      AppFeedback.error('Could not open the payment page.');
      return;
    }

    paying.value = true;
    final paid = await _waitForPayment(checkout.reference);
    paying.value = false;

    if (!paid) {
      AppFeedback.info(
        'We have not seen the payment yet. It will confirm here once it '
        'lands.',
      );
      return;
    }
    Get.offNamed(AppRoutes.paymentSuccess, arguments: held);
  }

  /// Whether the payment is being waited on, so the button can say so.
  final RxBool paying = false.obs;

  /// Ask the server, a few times, whether the webhook has arrived.
  ///
  /// Bounded: a payment that has not landed in a minute has probably been
  /// abandoned, and the session keeps its hold either way.
  Future<bool> _waitForPayment(String reference) async {
    for (var attempt = 0; attempt < 12; attempt++) {
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

  /// "Continue" on the receipt — the confirmation, and the end of the chain.
  void done() =>
      Get.offNamed(AppRoutes.bookingConfirmed, arguments: session ?? booked);

  /// The policy panel summarises; `280:26738` spells it out.
  void openPolicy() => Get.toNamed(AppRoutes.cancellationPolicy);
}
