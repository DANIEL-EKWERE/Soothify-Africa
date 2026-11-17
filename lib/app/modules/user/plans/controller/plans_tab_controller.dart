import 'package:get/get.dart';

import '../../../../core/base_controller.dart';
import '../../../../data/models/app_tab.dart';
import '../../../../data/models/plan_tier.dart';
import '../../../../data/repositories/billing_repository.dart';
import '../../../../data/repositories/subscription_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../shell/controller/shell_controller.dart';

/// Backs the Plans tab — Figma "Plans" (135:2444).
class PlansTabController extends BaseController {
  PlansTabController(this._repository, this._billing);

  final SubscriptionRepository _repository;
  final BillingRepository _billing;

  final Rx<BillingPeriod> period = BillingPeriod.monthly.obs;
  final RxList<PlanTier> tiers = <PlanTier>[].obs;


  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        tiers.assignAll(await _repository.getTiers(period.value));
      });

  void selectPeriod(BillingPeriod value) {
    if (value == period.value) return;
    period.value = value;
    load();
  }

  /// The redrawn screen sells the trial rather than a chosen tier, so the
  /// button no longer waits on a selection — the cards are not selectable.
  void startTrial() => Get.toNamed(AppRoutes.subscriptionOffer);

  /// The Passport card. The tier ladder before one is held, the Hub after.
  ///
  /// Asked of the server rather than remembered: this card is the way back
  /// into the Passport, and sending somebody who already pays for one to a
  /// screen that offers to sell them another is the worse mistake of the
  /// two. A membership that cannot be read falls through to the ladder,
  /// which refuses politely at checkout if it turns out they have one.
  Future<void> openPassport() async {
    final membership = await guard(
      () => _billing.membership(),
      showFeedback: false,
    );
    await Get.toNamed(
      membership?.hasPassport == true
          ? AppRoutes.passportHub
          : AppRoutes.passportTiers,
    );
  }

  /// "Speak with Corporate Team" — Figma "Corporate form" (`259:36101`).
  void openCorporateForm() => Get.toNamed(AppRoutes.corporateForm);

  /// The arrow in the header: Plans is a tab, so "back" is the tab before it
  /// rather than a route to pop.
  void back() {
    if (Get.isRegistered<ShellController>()) {
      Get.find<ShellController>().current.value = AppTab.home;
      return;
    }
    if (Get.key.currentState?.canPop() ?? false) Get.back();
  }
}
