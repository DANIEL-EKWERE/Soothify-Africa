import 'package:flutter/widgets.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/intro_slide.dart';

class IntroController extends GetxController {
  final PageController pageController = PageController();
  final RxInt index = 0.obs;

  List<IntroSlide> get slides => IntroSlide.all;

  bool get isLast => index.value == slides.length - 1;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int value) => index.value = value;

  /// The design shows the same "Get started" label on every slide, so the
  /// button advances until the last panel and then leaves the carousel.
  void next() {
    if (isLast) {
      finish();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> finish() async {
    // First-run only: the carousel must not reappear on later launches.
    await PrefUtils().setIntroSeen(true);
    Get.offAllNamed(AppRoutes.personalize);
  }
}
