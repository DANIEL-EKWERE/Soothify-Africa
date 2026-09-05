import 'package:get/get.dart';

import '../controller/booking_controller.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(BookingController.new);
}
