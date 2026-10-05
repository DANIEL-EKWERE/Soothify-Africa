import '../../../../core/app_export.dart';
import '../../../../data/models/membership.dart';

/// Backs "Your Subscription", "Change Your Plan" and "Billing History" —
/// Figma `308:25746`, `308:25763`, `308:25791`, `308:25888`, `308:25859` and
/// `308:25844`, the Manage-subscription set added on 2026-10-05.
///
/// Nothing bills anybody yet. The state is held here so the screens can be
/// walked and reviewed; when a payment provider is wired in, this is the one
/// place that has to start reading from it.
class SubscriptionManageController extends GetxController {
  /// The frame draws the trial, so that is what the app opens on.
  final Rx<SubscriptionState> state = SubscriptionState.trial.obs;

  final Rx<MembershipPlan> plan = MembershipPlan.annual.obs;

  /// What "Change Your Plan" has highlighted, which is not the live plan
  /// until the change is confirmed.
  late final Rx<MembershipPlan> choice = plan.value.obs;

  /// The dates and the card are the frame's own.
  String get renewalDate => 'October 9, 2026';
  String get firstCharge => '₦150,000';
  String get card => 'Mastercard ending in •••••';

  List<Invoice> get invoices =>
      state.value == SubscriptionState.inactive ? const [] : Invoice.sample;

  bool get isActive => state.value != SubscriptionState.inactive;

  /// The badge over the card: the trial says so, because that is the thing a
  /// person checks this screen to find out.
  String get statusLabel => switch (state.value) {
        SubscriptionState.inactive => 'Inactive',
        SubscriptionState.trial => 'Active · Free Trial',
        SubscriptionState.active => 'Active',
      };

  String get renewalCopy => state.value == SubscriptionState.trial
      ? 'Your free trial ends on $renewalDate. First charge of $firstCharge '
          'will occur then.'
      : 'Your membership renews on $renewalDate. You will be charged '
          '$firstCharge.';

  void startTrial() => Get.toNamed(AppRoutes.subscriptionOffer);

  void openBillingHistory() => Get.toNamed(AppRoutes.billingHistory);

  void openChangePlan() {
    choice.value = plan.value;
    Get.toNamed(AppRoutes.changePlan);
  }

  void choose(MembershipPlan value) => choice.value = value;

  bool get canConfirmPlan => choice.value != plan.value;

  void confirmPlanChange() {
    if (!canConfirmPlan) {
      Get.back();
      return;
    }
    plan.value = choice.value;
    Get.back();
    AppFeedback.info(
      'Switched to ${plan.value.name}. Nothing is billed yet — payments are '
      'not connected.',
    );
  }

  void updatePaymentMethod() =>
      AppFeedback.info('Changing the card is not connected yet.');

  void downloadInvoice(Invoice invoice) =>
      AppFeedback.info('Receipts are not available to download yet.');

  /// Leaves the subscription running. The frame makes this the filled button,
  /// so it is the easier of the two to hit.
  void keepSubscription() => Get.back();

  void confirmCancellation() {
    Get.back();
    state.value = SubscriptionState.inactive;
    AppFeedback.info(
      'Cancelled here, but nothing was sent — billing is not connected yet.',
    );
  }
}
