import 'package:get/get.dart';

import '../../../../data/repositories/booking_repository.dart';
import '../controller/booking_calendar_controller.dart';

class BookingCalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => BookingCalendarController(Get.find<BookingRepository>()),
    );
  }
}
