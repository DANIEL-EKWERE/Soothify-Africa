import 'package:get/get.dart';

import '../../../../core/base_controller.dart';
import '../../../../data/models/app_tab.dart';
import '../../../../data/models/plan_tier.dart';
import '../../../../data/repositories/subscription_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../shell/controller/shell_controller.dart';

/// Backs the Plans tab — Figma "Plans" (135:2444).
class PlansTabController extends BaseController {
  PlansTabController(this._repository);

  final SubscriptionRepository _repository;

  final Rx<BillingPeriod> period = BillingPeriod.monthly.obs;
  final RxList<PlanTier> tiers = <PlanTier>[].obs;

  /// Which card the user has tapped, by [PlanTier.id]. Null until one is —
  /// the screen opens with nothing chosen, every card on the resting
  /// hairline.
  final RxnString chosen = RxnString();

  void choose(String id) => chosen.value = id;


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
