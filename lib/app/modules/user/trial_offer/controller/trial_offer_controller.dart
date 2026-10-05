import '../../../../core/app_export.dart';
import '../../../../data/models/membership.dart';

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
class TrialOfferController extends GetxController {
  /// The frame opens with Annual chosen and its tick showing.
  final Rx<MembershipPlan> plan = MembershipPlan.annual.obs;

  /// The card form is the one the taller frame expands, so it is the default.
  final Rx<PaymentMethod> method = PaymentMethod.card.obs;

  final RxString promo = ''.obs;

  /// The dates and amounts the frames print.
  String get firstChargeDate => 'October 9, 2026';
  String get renewal => plan.value.billed;
  String get firstCharge =>
      plan.value == MembershipPlan.annual ? '₦150,000' : '₦15,000';

  /// Nothing is taken during the trial, which is the whole pitch.
  String get dueToday => '₦0.00';

  void choosePlan(MembershipPlan value) => plan.value = value;

  void chooseMethod(PaymentMethod value) => method.value = value;

  void openPayment() => Get.toNamed(AppRoutes.trialPayment);

  void restorePurchase() =>
      AppFeedback.info('Restoring a purchase is not built yet.');

  void applyPromo() {
    if (promo.value.trim().isEmpty) {
      AppFeedback.error('Enter a promo code first.');
      return;
    }
    AppFeedback.info('Promo codes are not checked yet.');
  }

  /// No payment provider is wired in, so this says so rather than appearing
  /// to take a card.
  void startFreeWeek() =>
      AppFeedback.info('Checkout is not connected yet — nothing was charged.');
}
