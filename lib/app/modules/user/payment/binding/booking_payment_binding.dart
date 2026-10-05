import 'package:get/get.dart';

import '../../../../data/models/booked_slot.dart';
import '../../../../data/models/session_offering.dart';
import '../controller/booking_payment_controller.dart';

/// Takes the offering from the route arguments; it carries both prices and
/// whether the cancellation policy is spelled out.
///
/// Shared by the payment screen and its receipt, so the receipt knows what
/// was paid for without the amount being passed twice.
class BookingPaymentBinding extends Bindings {
  @override
  void dependencies() {
    // Two shapes: the calendar sends a [BookedSlot] with the chosen time on
    // it, and the older entry points send a bare offering.
    final booked = Get.arguments is BookedSlot ? Get.arguments as BookedSlot : null;
    final offering = booked?.offering ??
        (Get.arguments is SessionOffering
            ? Get.arguments as SessionOffering
            : SessionOffering.therapy);
    Get.lazyPut(() => BookingPaymentController(offering, booked: booked));
  }
}
