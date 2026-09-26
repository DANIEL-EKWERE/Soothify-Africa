import 'package:get/get.dart';

import '../../../../data/models/subscription_offer.dart';
import '../controller/subscription_offer_controller.dart';

/// Takes the offer from the route arguments, so one route serves both frames.
class SubscriptionOfferBinding extends Bindings {
  @override
  void dependencies() {
    final offer = Get.arguments is SubscriptionOffer
        ? Get.arguments as SubscriptionOffer
        : SubscriptionOffer.trial;
    Get.lazyPut(() => SubscriptionOfferController(offer));
  }
}
