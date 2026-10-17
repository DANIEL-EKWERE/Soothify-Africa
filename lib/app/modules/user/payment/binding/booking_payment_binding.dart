import 'package:get/get.dart';

import '../../../../data/models/booked_session.dart';
import '../../../../data/models/booked_slot.dart';
import '../../../../data/models/session_offering.dart';
import '../../../../data/repositories/billing_repository.dart';
import '../controller/booking_payment_controller.dart';

/// Takes whatever the previous screen sent, in one of three shapes.
///
/// The calendar now books before paying, so it sends a [BookedSession] the
/// server is holding. Older entry points send a [BookedSlot] or a bare
/// offering, and those still have to work -- they reach the same screens.
class BookingPaymentBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final session = args is BookedSession ? args : null;
    final booked = args is BookedSlot ? args : null;
    final offering = session?.offering ??
        booked?.offering ??
        (args is SessionOffering ? args : SessionOffering.therapy);

    Get.lazyPut(
      () => BookingPaymentController(
        offering,
        Get.find<BillingRepository>(),
        booked: booked,
        session: session,
      ),
    );
  }
}
