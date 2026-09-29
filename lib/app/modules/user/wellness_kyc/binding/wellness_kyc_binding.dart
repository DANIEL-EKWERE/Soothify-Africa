import 'package:get/get.dart';

import '../../../../core/utils/wellness_entry.dart';
import '../../../../data/models/wellness_kyc.dart';
import '../controller/wellness_kyc_controller.dart';

class WellnessKycBinding extends Bindings {
  @override
  void dependencies() {
    // Either shape: a bare track from the older callers, or a [KycEntry] from
    // a card that also says whether to skip the interstitial.
    final argument = Get.arguments;
    final entry = switch (argument) {
      KycEntry e => e,
      WellnessTrack t => KycEntry(t),
      _ => const KycEntry(WellnessTrack.meditation),
    };
    Get.lazyPut(
      () => WellnessKycController(entry.track, skipIntro: entry.skipIntro),
    );
  }
}
