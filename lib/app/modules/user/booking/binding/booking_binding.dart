import 'package:get/get.dart';

import '../../../../data/models/session_offering.dart';
import '../controller/booking_controller.dart';

/// Takes the offering the receipt hands over, so the matching interstitial
/// can name the discipline.
class BookingBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() {
        final args = Get.arguments;
        // Two callers: the receipt passes a bare offering, and the joining
        // screen passes an entry that also says where to begin.
        if (args is BookingEntry) {
          return BookingController(
            offering: args.offering,
            startAt: args.stage,
            startMode: args.mode,
          );
        }
        return BookingController(
          offering: args is SessionOffering ? args : null,
        );
      });
}
