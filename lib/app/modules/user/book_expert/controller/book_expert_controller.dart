import 'package:get/get.dart';

import '../../../../core/utils/wellness_entry.dart';
import '../../../../data/models/expert_session_type.dart';
import '../../../../data/models/wellness_kyc.dart';

/// "Book a licensed expert screen" — Figma `259:31488`.
///
/// The screen is a fixed list of three, so there is nothing to load; the
/// controller exists to own where a card goes.
class BookExpertController extends GetxController {
  List<ExpertSessionType> get offers => ExpertSessionType.values;

  /// Each card opens its own questionnaire, without the interstitial.
  ///
  /// The yoga card and Stretch & Restore share one: `Scheduling Kyc/Yoga`
  /// (259:38802) plus the `Yoga Kyc` row is that section's questionnaire, and
  /// yoga is what it asks about. The Pilates card shares Pilates & Core's for
  /// the same reason — the design draws no separate expert-Pilates row.
  ///
  /// `skipIntro` because a card has already named the discipline; being told
  /// "Tailoring your practice" after choosing a yoga session is a screen that
  /// introduces something the user just picked.
  Future<void> book(ExpertSessionType offer) =>
      openBooking(trackFor(offer), skipIntro: true);

  /// Which questionnaire a card opens. Separate from [book] so the mapping
  /// can be asserted without driving navigation.
  WellnessTrack trackFor(ExpertSessionType offer) => switch (offer) {
        ExpertSessionType.therapy => WellnessTrack.therapy,
        ExpertSessionType.yoga => WellnessTrack.balance,
        ExpertSessionType.pilates => WellnessTrack.meditation,
      };
}
