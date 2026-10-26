import 'package:intl/intl.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../core/utils/checkout_launcher.dart';
import '../../checkout/checkout_webview_screen.dart' show CheckoutOutcome;
import '../../../../data/models/checkout.dart';
import '../../../../data/models/membership.dart';
import '../../../../data/repositories/billing_repository.dart';

/// Backs "Your Subscription", "Change Your Plan" and "Billing History" —
/// Figma `308:25746`, `308:25763`, `308:25791`, `308:25888`, `308:25859` and
/// `308:25844`, the Manage-subscription set added on 2026-10-05.
///
/// Nothing bills anybody yet. The state is held here so the screens can be
/// walked and reviewed; when a payment provider is wired in, this is the one
/// place that has to start reading from it.
class SubscriptionManageController extends BaseController {
  SubscriptionManageController(this._billing);

  final BillingRepository _billing;

  /// Where the account actually stands. Starts inactive and is replaced by
  /// what the server says -- the frame draws a trial, but a screen that
  /// claims a membership nobody has is worse than one that loads.
  final Rx<SubscriptionState> state = SubscriptionState.inactive.obs;

  /// Everything the server knows about the membership, for the dates and
  /// the card the screen prints.
  final Rx<MembershipStatus> status = MembershipStatus.none.obs;

  final RxList<BillingInvoice> billingHistory = <BillingInvoice>[].obs;

  final Rx<MembershipPlan> plan = MembershipPlan.annual.obs;

  /// What "Change Your Plan" has highlighted, which is not the live plan
  /// until the change is confirmed.
  late final Rx<MembershipPlan> choice = plan.value.obs;

  @override
  void onInit() {
    super.onInit();
    refreshMembership();
  }

  Future<void> refreshMembership() async {
    final found = await guard(() => _billing.membership());
    if (found == null) return;

    status.value = found;
    state.value = switch (found.state) {
      'trial' => SubscriptionState.trial,
      'active' => SubscriptionState.active,
      // Past due and cancelled both still have a period left to run, which
      // the renewal copy explains; neither is "never subscribed".
      'past_due' || 'cancelled' => SubscriptionState.active,
      _ => SubscriptionState.inactive,
    };
    if (found.planKey.isNotEmpty) {
      plan.value = found.cadence == 'monthly'
          ? MembershipPlan.monthly
          : MembershipPlan.annual;
    }

    // Asked for whatever the state: somebody who cancelled should still be
    // able to see what they were charged. Quietly, because Billing History
    // draws its own empty state and this also runs behind other screens.
    final history = await guard(
      () => _billing.invoices(),
      showFeedback: false,
    );
    billingHistory.value = history ?? const [];
  }

  /// The dates and the card, from the server. The frame's own strings stand
  /// in only until it has answered -- a screen about money should not print
  /// a date nobody will be charged on.
  String get renewalDate {
    final when = status.value.renewsAt ?? status.value.trialEndsAt;
    return when == null
        ? '—'
        : DateFormat('MMMM d, y').format(when);
  }

  String get firstCharge => status.value.nextChargeNaira > 0
      ? '₦${NumberFormat.decimalPattern('en').format(status.value.nextChargeNaira)}'
      : plan.value.billed;

  String get card =>
      status.value.card.isEmpty ? 'No card saved' : status.value.card;

  List<Invoice> get invoices => billingHistory
      .map(
        (row) => Invoice(
          date: row.paidAt == null
              ? '—'
              : DateFormat('MMM d, y').format(row.paidAt!),
          amount: '₦${NumberFormat.decimalPattern('en').format(row.amountNaira)}',
          description: row.description,
          status: row.statusLabel,
        ),
      )
      .toList();

  bool get isActive => state.value != SubscriptionState.inactive;

  /// The badge over the card: the trial says so, because that is the thing a
  /// person checks this screen to find out.
  String get statusLabel => switch (state.value) {
        SubscriptionState.inactive => 'Inactive',
        SubscriptionState.trial => 'Active · Free Trial',
        SubscriptionState.active => 'Active',
      };

  /// Whether the date below is a renewal or an ending.
  ///
  /// A membership sold one period at a time is not charged again by itself:
  /// saying it "renews" would leave somebody expecting access they are
  /// about to lose.
  bool get renewsItself => status.value.autoRenew;

  /// Whether the free week is still on offer for this account.
  bool get trialAvailable => status.value.trialAvailable;

  /// What the inactive card's button says. There is one free week each;
  /// after that the same button sells a period.
  String get startLabel =>
      trialAvailable ? 'Start 7-Day Free Trial' : 'Start Membership';

  String get renewalCopy {
    if (state.value == SubscriptionState.trial) {
      return renewsItself
          ? 'Your free trial ends on $renewalDate. First charge of '
              '$firstCharge will occur then.'
          : 'Your free trial ends on $renewalDate. Pay $firstCharge before '
              'then to keep your membership.';
    }
    return renewsItself
        ? 'Your membership renews on $renewalDate. You will be charged '
            '$firstCharge.'
        : 'Your membership ends on $renewalDate. Renew for $firstCharge to '
            'keep your access.';
  }

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

  /// "Update payment method".
  ///
  /// Opens a checkout that charges the new card the provider's smallest
  /// amount and gives it straight back -- the only way to save a naira
  /// card. Said before it opens, because the money does leave their
  /// account and their bank takes a few days to show it returning.
  Future<void> updatePaymentMethod() async {
    if (isLoading.value) return;

    final checkout = await guard(() => _billing.replaceCard());
    if (checkout == null) return;

    if (checkout.checkoutUrl.isEmpty) {
      AppFeedback.info('Payments are not connected yet — nothing was charged.');
      return;
    }

    final outcome = await CheckoutLauncher.present(
      checkout,
      title: 'Update your card',
    );
    if (outcome == CheckoutOutcome.failed) {
      AppFeedback.error('Could not open the payment page.');
      return;
    }

    AppFeedback.info(
      checkout.cardCheckNaira > 0
          ? 'We take ₦${checkout.cardCheckNaira} to check the new card and '
              'send it straight back.'
          : 'Your card is updated once the change is confirmed.',
    );
  }

  void downloadInvoice(Invoice invoice) =>
      AppFeedback.info('Receipts are not available to download yet.');

  /// Leaves the subscription running. The frame makes this the filled button,
  /// so it is the easier of the two to hit.
  void keepSubscription() => Get.back();

  Future<void> confirmCancellation() async {
    Get.back();

    final after = await guard(() => _billing.cancelMembership());
    if (after == null) return;      // guard has said why; nothing changed

    status.value = after;
    // Cancelled, but paid up: access runs to the end of the period, and the
    // screen should not pretend it stopped today.
    state.value = after.isActive
        ? SubscriptionState.active
        : SubscriptionState.inactive;
    AppFeedback.info(
      after.renewsAt == null
          ? 'Your membership is cancelled.'
          : 'Cancelled. You keep access until '
              '${DateFormat('MMMM d').format(after.renewsAt!)}.',
    );
  }
}
