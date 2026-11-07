import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../core/utils/checkout_launcher.dart';
import '../../checkout/checkout_webview_screen.dart' show CheckoutOutcome;
import '../../../../data/models/membership.dart';
import '../../../../core/utils/card_input.dart' as card;
import '../../../../data/repositories/billing_repository.dart';

/// How the trial is paid for — Figma `311:25477` (card) and `311:25582`
/// (Apple Pay) draw the same screen with one or the other chosen.
enum PaymentMethod {
  applePay('Apple Pay'),
  card('Credit card');

  const PaymentMethod(this.label);

  final String label;
}

/// Backs the trial pop-up and the payment screen behind it — Figma
/// `311:25655`, `311:25477` and `311:25582`, redrawn 2026-10-05.
class TrialOfferController extends BaseController {
  TrialOfferController(this._billing, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final BillingRepository _billing;

  /// Injected so a golden can pin the dates this screen prints.
  final DateTime Function() _now;

  /// The free week, as the frames describe it.
  static const int trialDays = 7;

  /// The frame opens with Annual chosen and its tick showing.
  final Rx<MembershipPlan> plan = MembershipPlan.annual.obs;

  /// The card form is the one the taller frame expands, so it is the default.
  final Rx<PaymentMethod> method = PaymentMethod.card.obs;

  final RxString promo = ''.obs;

  // ---------------------------------------------------------------- //
  // The card form.                                                     //
  //                                                                    //
  // Held here rather than in the widget so what was typed survives a   //
  // rebuild, and so the errors can be checked without pumping the      //
  // screen. The fields used to carry no controller at all: anything    //
  // could be typed, nothing was kept, and nothing complained.          //
  // ---------------------------------------------------------------- //

  final cardholder = TextEditingController();
  final cardNumber = TextEditingController();
  final expiry = TextEditingController();
  final securityCode = TextEditingController();

  /// Which fields have been left once, so an error shows after somebody
  /// has had their go at a field rather than while they are still in it.
  final RxSet<String> touched = <String>{}.obs;

  /// Bumped on every keystroke: a TextEditingController is not observable,
  /// and the errors below have to be recomputed as the card is typed.
  final RxInt cardEdits = 0.obs;

  void touchCard() => cardEdits.value++;

  void blur(String field) {
    touched.add(field);
    touchCard();
  }

  String? _shown(String field, String? error) =>
      touched.contains(field) ? error : null;

  String? get cardholderError =>
      _shown('name', card.cardholderError(cardholder.text));

  String? get cardNumberError =>
      _shown('number', card.cardNumberError(cardNumber.text));

  String? get expiryError =>
      _shown('expiry', card.expiryError(expiry.text, now: _now()));

  String? get securityCodeError => _shown(
        'code',
        card.securityCodeError(
          securityCode.text,
          cardNumber: cardNumber.text,
        ),
      );

  /// Whether the card as typed could be sent. Read without regard to
  /// [touched]: a field nobody has visited is still empty and still wrong.
  bool get cardIsComplete {
    cardEdits.value;
    return card.cardholderError(cardholder.text) == null &&
        card.cardNumberError(cardNumber.text) == null &&
        card.expiryError(expiry.text, now: _now()) == null &&
        card.securityCodeError(
              securityCode.text,
              cardNumber: cardNumber.text,
            ) ==
            null;
  }

  /// What the card says it is, for the mark beside the number.
  card.CardBrand get cardBrand =>
      card.CardBrand.of(card.onlyDigits(cardNumber.text));

  /// When the first charge falls, counted from today.
  ///
  /// The frame prints a fixed date, which was fine while nothing was being
  /// charged. It is not fine now: this is the day money leaves somebody's
  /// account, and it has to be the day it actually leaves.
  DateTime get firstChargeOn =>
      _now().add(const Duration(days: trialDays));

  String get firstChargeDate => DateFormat('MMMM d, y').format(firstChargeOn);

  /// The same date as the frame's short form, beside the price.
  String get firstChargeShort => DateFormat('MMM d, y').format(firstChargeOn);

  String get renewal => plan.value.billed;
  String get firstCharge =>
      plan.value == MembershipPlan.annual ? '₦150,000' : '₦15,000';

  /// Nothing is taken during the trial, which is the whole pitch.
  String get dueToday => '₦0.00';

  /// What the week asks for before it starts, read from the server so the
  /// figure here and the charge there cannot drift apart.
  final RxInt cardCheckNaira = 0.obs;

  /// The sentence under "Due today", when a card is asked for.
  ///
  /// Said before the button, not after: the money does leave their account,
  /// and their bank takes its own few days to show it coming back. Somebody
  /// who finds out afterwards is right to feel misled.
  String get cardCheckNote {
    final naira = cardCheckNaira.value;
    if (naira <= 0) return '';
    return 'We take ₦$naira to check your card and send it back straight '
        'away. Your bank may take a few days to show it.';
  }

  @override
  void onInit() {
    super.onInit();
    _readTheOffer();
  }

  Future<void> _readTheOffer() async {
    final membership = await guard(
      () => _billing.membership(),
      // The pop-up stands up without this; it just says less.
      showFeedback: false,
    );
    if (membership == null) return;
    cardCheckNaira.value =
        membership.trialRequiresCard ? membership.cardCheckNaira : 0;
  }

  void choosePlan(MembershipPlan value) => plan.value = value;

  void chooseMethod(PaymentMethod value) => method.value = value;

  void openPayment() => Get.toNamed(AppRoutes.trialPayment);

  void restorePurchase() =>
      AppFeedback.info('Restoring a purchase is not built yet.');

  /// The code that was accepted, carried into checkout.
  final RxString promoApplied = ''.obs;

  Future<void> applyPromo() async {
    final code = promo.value.trim();
    if (code.isEmpty) {
      AppFeedback.error('Enter a promo code first.');
      return;
    }

    final found = await guard(() => _billing.checkPromo(code));
    if (found == null) {
      promoApplied.value = '';
      AppFeedback.error('That code cannot be used.');
      return;
    }

    promoApplied.value = code;
    final percent = found['percent_off'];
    final amount = found['amount_off_naira'];
    AppFeedback.info(
      percent != null
          ? '$percent% off applied.'
          : amount != null
              ? '\u20a6$amount off applied.'
              : 'Code applied.',
    );
  }

  /// Begin the free week.
  ///
  /// Two ways this can go, and the server decides which:
  ///
  /// With a saved card, nothing is charged today and the first cycle is
  /// billed when the seven days are up; the membership starts when the
  /// provider's webhook reaches the server, not when the browser closes.
  ///
  /// Sold a period at a time, there is no card to save, so the server
  /// grants the week outright and says so -- there is nothing to open and
  /// nothing to wait for.
  Future<void> startFreeWeek() async {
    if (isLoading.value) return;

    final annual = plan.value == MembershipPlan.annual;
    final checkout = await guard(() => _billing.startMembership(
          planKey: annual ? 'core-annual' : 'core-monthly',
          cadence: annual ? 'annual' : 'monthly',
          trial: true,
          promoCode: promoApplied.value,
        ));
    if (checkout == null) return;

    if (checkout.trialStarted) {
      Get.offAllNamed(AppRoutes.shell);
      AppFeedback.info(
        'Your free week has started. We will remind you before it ends.',
      );
      return;
    }

    if (checkout.checkoutUrl.isEmpty) {
      // No provider configured server-side. Said plainly, as before.
      AppFeedback.info('Checkout is not connected yet — nothing was charged.');
      return;
    }

    // Same web view as the booking flow, for the same reason: the payer
    // stays in the app, so this screen is still here afterwards.
    final outcome = await CheckoutLauncher.present(
      checkout,
      title: 'Start your free week',
    );
    if (outcome == CheckoutOutcome.failed) {
      AppFeedback.error('Could not open the payment page.');
      return;
    }

    // Still the webhook that decides, so this says what is pending rather
    // than announcing a trial that has not begun.
    AppFeedback.info(
      checkout.cardCheckNaira > 0
          ? 'Your week starts as soon as the card is confirmed, and the '
              '₦${checkout.cardCheckNaira} goes back.'
          : 'Your trial starts as soon as the card is confirmed.',
    );
  }

  @override
  void onClose() {
    cardholder.dispose();
    cardNumber.dispose();
    expiry.dispose();
    securityCode.dispose();
    super.onClose();
  }
}
