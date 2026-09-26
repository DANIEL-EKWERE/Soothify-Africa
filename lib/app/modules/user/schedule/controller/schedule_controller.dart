import '../../../../core/app_export.dart';
import '../../../../data/models/session_offering.dart';

/// Backs Schedule — Figma "Schedule screen" (135:20771).
class ScheduleController extends GetxController {
  List<SessionOffering> get offerings => SessionOffering.values;

  /// Payment comes first: the frames put it under the Schedule header and
  /// its copy — "Secure your spot to unlock your calendar link" — says
  /// plainly that the calendar is what it buys. The offering carries the
  /// prices, so the three payment frames are one screen.
  ///
  /// After the receipt, [AppRoutes.booking] runs matching, the communication
  /// method, the call, then rating and feedback.
  void book(SessionOffering offering) =>
      Get.toNamed(AppRoutes.bookingPayment, arguments: offering);
}
