import 'package:get/get.dart';

import '../../../../data/repositories/booking_repository.dart';

import '../controller/client_joining_controller.dart';

class ClientJoiningBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClientJoiningController(
          // So the screen can tell whether it is time yet.
          bookings: Get.isRegistered<BookingRepository>()
              ? Get.find<BookingRepository>()
              : null,
        ));
  }
}
