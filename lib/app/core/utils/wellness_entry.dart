import '../../data/models/wellness_kyc.dart';
import '../app_export.dart';

/// Opens a section's booking flow, asking its questionnaire the first time.
///
/// Shared by Home's Explore tiles, the "Book a licensed expert" cards and the
/// section sessions cards, so the gate cannot be wired one way in one place
/// and another way somewhere else.
///
/// Either path ends at the match. Someone who has already answered skips
/// straight to it; `ScheduleScreen`'s three gradient cards used to sit here
/// and are no longer part of the design.
Future<void> openBooking(WellnessTrack track, {bool skipIntro = false}) async {
  if (PrefUtils().wellnessKycDone(track.name)) {
    await Get.toNamed(AppRoutes.booking, arguments: track.offering);
    return;
  }
  await Get.toNamed(
    AppRoutes.wellnessKyc,
    arguments: KycEntry(track, skipIntro: skipIntro),
  );
}

/// What the questionnaire route is opened with.
///
/// A record rather than a bare [WellnessTrack] because the same track is
/// reached two ways — from its section, which shows the interstitial, and
/// from a card on "Book a licensed expert screen", which does not.
class KycEntry {
  const KycEntry(this.track, {this.skipIntro = false});

  final WellnessTrack track;
  final bool skipIntro;
}
