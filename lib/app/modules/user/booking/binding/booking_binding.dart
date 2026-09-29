import 'package:get/get.dart';

import '../../../../data/models/session_offering.dart';
import '../controller/booking_controller.dart';

/// Takes the offering the receipt hands over, so the matching interstitial
/// can name the discipline.
class BookingBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(
        () => BookingController(
          offering: Get.arguments is SessionOffering
              ? Get.arguments as SessionOffering
              : null,
        ),
      );
}
