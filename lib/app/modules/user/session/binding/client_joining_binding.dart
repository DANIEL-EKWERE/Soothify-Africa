import 'package:get/get.dart';

import '../controller/client_joining_controller.dart';

class ClientJoiningBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(ClientJoiningController.new);
  }
}
