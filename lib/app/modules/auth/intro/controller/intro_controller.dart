import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/intro_slide.dart';

class IntroController extends GetxController {
  IntroController({Duration? autoAdvance})
      : _interval = autoAdvance ?? const Duration(seconds: 4);

  /// How long each slide holds before the carousel moves itself on.
  ///
  /// [Duration.zero] disables it, which is what a golden of a specific slide
  /// needs — otherwise the page moves out from under the capture.
  final Duration _interval;

  final PageController pageController = PageController();
  final RxInt index = 0.obs;

  /// Whether the automatic move slides or cuts. Set by the screen from the
  /// platform's reduce-motion setting: the carousel still advances, it just
  /// does not animate.
  bool animateAutoAdvance = true;

  Timer? _timer;

  List<IntroSlide> get slides => IntroSlide.all;

  bool get isLast => index.value == slides.length - 1;

  @override
  void onInit() {
    super.onInit();
    _restartTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (_interval == Duration.zero) return;
    _timer = Timer.periodic(_interval, (_) => _advance());
  }

  /// Moves on by itself, and stops once it reaches the last slide.
  ///
  /// It does not wrap back to the first: the last panel is where the action
  /// is, and a carousel that keeps sliding away from the button is one the
  /// user has to chase.
  void _advance() {
    if (isLast || !pageController.hasClients) {
      _timer?.cancel();
      return;
    }
    final next = index.value + 1;
    if (animateAutoAdvance) {
      pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    } else {
      pageController.jumpToPage(next);
    }
  }

  /// A swipe — the user's or the timer's — buys the new slide a full
  /// interval, so the page never slides away just after being dragged in.
  void onPageChanged(int value) {
    index.value = value;
    _restartTimer();
  }

  /// "Get started" — out of the carousel, from any slide.
  ///
  /// It used to step to the next panel and only leave from the last one,
  /// which made the one button on the screen read as "Next". The carousel
  /// advances itself; the button is the way out of it.
  Future<void> start() => finish();

  /// "Skip" — straight into the app without an account.
  ///
  /// Guests are first-class here: the shell, Home, Discovery and the sessions
  /// all work without signing in, and Profile is where an account is offered.
  /// So Skip lands on the dashboard rather than on a sign-up wall.
  ///
  /// It records that onboarding was declined, so the next launch does not
  /// send the user back to the questionnaire they just skipped.
  Future<void> skip() async {
    await PrefUtils().setIntroSeen(true);
    await PrefUtils().setOnboardingSkipped(true);
    Get.offAllNamed(AppRoutes.shell);
  }

  Future<void> finish() async {
    // First-run only: the carousel must not reappear on later launches.
    await PrefUtils().setIntroSeen(true);
    Get.offAllNamed(AppRoutes.personalize);
  }
}
