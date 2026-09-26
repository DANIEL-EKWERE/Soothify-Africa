import '../../../../core/app_export.dart';
import '../../../../data/models/subscription_offer.dart';

/// Backs the subscription pop-up — Figma `259:59011` and `259:58598`.
class SubscriptionOfferController extends GetxController {
  SubscriptionOfferController(this.offer);

  final SubscriptionOffer offer;

  /// The frame draws Annual chosen, with the tick on its card.
  final Rx<OfferPeriod> period = OfferPeriod.annual.obs;

  void choose(OfferPeriod value) => period.value = value;

  /// No payment provider is wired. The pop-up is the pitch; taking money is
  /// not built, and saying it is would be a claim about a charge.
  void subscribe() => AppFeedback.info('Checkout is not built yet.');

  void restore() =>
      AppFeedback.info('Restoring a purchase is not built yet.');

  /// "Not sure? Learn about our free year" — nothing is drawn behind it.
  void learnMore() =>
      AppFeedback.info('There is nothing behind this link yet.');
}
