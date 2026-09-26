import 'package:get/get.dart';

import '../../../../data/repositories/journal_repository.dart';
import '../controller/journal_controller.dart';

class JournalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => JournalController(Get.find<JournalRepository>()));
  }
}
