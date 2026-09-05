import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/coach.dart';

/// How the session is taken. The design offers exactly these two.
enum CallMode {
  phone('Phone call'),
  video('Video call');

  const CallMode(this.label);

  final String label;
}

/// Where the booking flow currently is — Figma 135:20803 onward.
enum BookingStage { matching, matched, method, call, rating, feedback }

/// Drives the booking flow after Schedule.
///
/// One controller rather than five routes: the frames share a header and run
/// strictly in order, and a back press should step back through the flow
/// rather than unwind a route stack the user never chose to build.
class BookingController extends GetxController {
  BookingController({Duration? matchDuration})
      : _matchDuration = matchDuration ?? const Duration(seconds: 3);

  /// How long the matching interstitial runs. Injectable so a test does not
  /// wait on a real timer.
  final Duration _matchDuration;

  final Rx<BookingStage> stage = BookingStage.matching.obs;
  final Rxn<CallMode> mode = Rxn<CallMode>();
  final RxInt rating = 0.obs;
  final RxDouble matchProgress = 0.0.obs;
  final TextEditingController feedback = TextEditingController();

  /// The matched coach. The backend will supply this once matching is real.
  Coach get coach => Coach.sample;

  String get coachName => coach.name;

  /// The date chosen in the "Schedule for later" sheet, if any.
  final Rxn<DateTime> scheduledFor = Rxn<DateTime>();

  /// The month the calendar sheet is showing. The design prints June 2024.
  final Rx<DateTime> calendarMonth = DateTime(2024, 6).obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _runMatching();
  }

  @override
  void onClose() {
    _timer?.cancel();
    feedback.dispose();
    super.onClose();
  }

  /// The frame draws the progress bar part-filled (128 of 281), so it is an
  /// indeterminate wait shown as progress rather than a real measurement.
  void _runMatching() {
    const tick = Duration(milliseconds: 100);
    var elapsed = Duration.zero;
    _timer = Timer.periodic(tick, (t) {
      elapsed += tick;
      matchProgress.value =
          (elapsed.inMilliseconds / _matchDuration.inMilliseconds)
              .clamp(0.0, 1.0);
      if (matchProgress.value >= 1.0) {
        t.cancel();
        stage.value = BookingStage.matched;
      }
    });
  }

  /// "Get started" — straight into choosing how to connect.
  void getStarted() => stage.value = BookingStage.method;

  /// "Schedule for later" — the calendar sheet picks a date instead.
  void schedule(DateTime date) {
    scheduledFor.value = date;
    AppFeedback.info(
      'Session set for ${date.day}/${date.month}/${date.year}. '
      'Confirmation is not built yet.',
    );
  }

  void chooseMode(CallMode value) {
    mode.value = value;
    stage.value = BookingStage.call;
  }

  void endCall() => stage.value = BookingStage.rating;

  void rate(int stars) {
    rating.value = stars;
    stage.value = BookingStage.feedback;
  }

  bool get canPost => feedback.text.trim().isNotEmpty;

  void post() {
    if (!canPost) return;
    AppFeedback.info('Thanks — sending feedback is not built yet.');
    Get.until((route) => Get.currentRoute == AppRoutes.shell);
  }

  /// Steps back through the flow; leaves the route only from the first stage.
  void back() {
    switch (stage.value) {
      case BookingStage.matching:
        Get.back();
      case BookingStage.matched:
        Get.back();
      case BookingStage.method:
        stage.value = BookingStage.matched;
      case BookingStage.call:
        stage.value = BookingStage.method;
      case BookingStage.rating:
        stage.value = BookingStage.call;
      case BookingStage.feedback:
        stage.value = BookingStage.rating;
    }
  }
}
