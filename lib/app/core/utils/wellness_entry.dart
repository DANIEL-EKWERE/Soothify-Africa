import '../../data/models/wellness_kyc.dart';
import '../app_export.dart';

/// Opens a section's booking flow, asking its questionnaire the first time.
///
/// Shared by Home's "Schedule Session" tile and the Meditation and Balance
/// sessions cards, so the gate cannot be wired one way in one place and
/// another way somewhere else.
Future<void> openBooking(WellnessTrack track) async {
  if (PrefUtils().wellnessKycDone(track.name)) {
    await Get.toNamed(AppRoutes.schedule);
    return;
  }
  await Get.toNamed(AppRoutes.wellnessKyc, arguments: track);
}
