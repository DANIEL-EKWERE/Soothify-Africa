import 'package:get/get.dart';

import '../../../../data/models/checkin_kind.dart';
import '../../../../data/repositories/kyc_repository.dart';
import '../../../../data/repositories/mood_repository.dart';
import '../controller/checkin_controller.dart';

class CheckinBinding extends Bindings {
  @override
  void dependencies() {
    final kind = Get.arguments is CheckinKind
        ? Get.arguments as CheckinKind
        : CheckinKind.mood;
    // KYC comes in for the gender answer, which decides whose illustration a
    // recorded mood is drawn with.
    Get.lazyPut(
      () => CheckinController(
        Get.find<MoodRepository>(),
        Get.find<KycRepository>(),
        kind,
      ),
    );
  }
}
