import 'package:get/get.dart';

import '../controller/book_expert_controller.dart';

class BookExpertBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(BookExpertController.new);
  }
}
