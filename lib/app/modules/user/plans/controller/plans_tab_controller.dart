import 'package:get/get.dart';

import '../../../../core/base_controller.dart';
import '../../../../core/utils/feedback_utils.dart';
import '../../../../data/models/plan_tier.dart';
import '../../../../data/repositories/subscription_repository.dart';

/// Backs the Plans tab — Figma "Plans" (135:2444).
class PlansTabController extends BaseController {
  PlansTabController(this._repository);

  final SubscriptionRepository _repository;

  final Rx<BillingPeriod> period = BillingPeriod.monthly.obs;
  final RxList<PlanTier> tiers = <PlanTier>[].obs;

  /// Nothing is selected on the frame and the continue button is drawn at 45%,
  /// so an empty selection is the design's own initial state.
  final RxnString selectedTierId = RxnString();

  bool get canContinue => selectedTierId.value != null;

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

  void selectTier(String id) => selectedTierId.value = id;

  void proceed() {
    if (!canContinue) return;
    AppFeedback.info('Checkout is not built yet.');
  }
}
