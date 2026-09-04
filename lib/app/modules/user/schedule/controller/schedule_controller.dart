import '../../../../core/app_export.dart';
import '../../../../data/models/session_offering.dart';

/// Backs Schedule — Figma "Schedule screen" (135:20771).
class ScheduleController extends GetxController {
  List<SessionOffering> get offerings => SessionOffering.values;

  /// Booking runs through Matching instructor, Communication method, Calendar
  /// and Rating frames in the design; none are built.
  void book(SessionOffering offering) =>
      AppFeedback.info('Booking a ${offering.title.toLowerCase()} is not built yet.');
}
