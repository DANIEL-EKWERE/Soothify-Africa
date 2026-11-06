import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../../core/utils/initial_bindings.dart';
import '../../../data/repositories/api_partner_repository.dart';
import '../../../data/repositories/mock_partner_repository.dart';
import '../../../data/repositories/partner_repository.dart';
import '../controller/partner_controller.dart';
import '../controller/add_slot_controller.dart';
import '../controller/partner_ledger_controller.dart';
import '../controller/partner_schedule_controller.dart';
import '../controller/roster_controller.dart';

/// The partner role's dependencies.
///
/// Bound here rather than in [InitialBindings], for the reason the expert's
/// are: a member never touches these, and binding them at startup would ask
/// the studio endpoints for everyone.
class PartnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerRepository>(
      () => InitialBindings.useApi
          ? ApiPartnerRepository(Get.find<ApiClient>())
          : MockPartnerRepository(),
      fenix: true,
    );
    Get.lazyPut(() => PartnerController(Get.find<PartnerRepository>()));
    Get.lazyPut(() => PartnerLedgerController(Get.find<PartnerRepository>()));
    Get.lazyPut(() => PartnerScheduleController(Get.find<PartnerRepository>()));
    Get.lazyPut(() => AddSlotController(Get.find<PartnerRepository>()));
    Get.lazyPut(() => RosterController(Get.find<PartnerRepository>()));
  }
}
