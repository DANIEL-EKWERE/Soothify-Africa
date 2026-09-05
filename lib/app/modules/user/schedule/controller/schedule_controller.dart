import '../../../../core/app_export.dart';
import '../../../../data/models/session_offering.dart';

/// Backs Schedule — Figma "Schedule screen" (135:20771).
class ScheduleController extends GetxController {
  List<SessionOffering> get offerings => SessionOffering.values;

  /// Booking runs through matching, the communication method, the call, then
  /// rating and feedback — all one route, see [AppRoutes.booking].
  void book(SessionOffering offering) => Get.toNamed(AppRoutes.booking);
}
