import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/coach.dart';
import '../../../../data/models/session_offering.dart';

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
  BookingController({Duration? matchDuration, this.offering})
      : _matchDuration = matchDuration ?? const Duration(seconds: 3);

  /// What was booked. Null only when the route is opened without one, which
  /// the app does not do — the receipt always passes it.
  final SessionOffering? offering;

  /// The matching interstitial's heading. Names the discipline where the
  /// design says so, and falls back to the old file's generic line.
  String get matchingHeading =>
      offering?.matchingHeading ??
      'Pairing you with a wellness coach who suits your needs.';

  /// How long the matching interstitial runs. Injectable so a test does not
  /// wait on a real timer.
  final Duration _matchDuration;

  final Rx<BookingStage> stage = BookingStage.matching.obs;
  final Rxn<CallMode> mode = Rxn<CallMode>();
  final RxInt rating = 0.obs;
  final RxDouble matchProgress = 0.0.obs;

  /// Whether the match celebration is still owed — Figma `259:31992`, which
  /// is the plain matched frame (`259:31617`) plus a burst of confetti.
  ///
  /// Latches false once it has played, so stepping back to the matched screen
  /// from "Get started" lands on the plain frame. A celebration that fires
  /// every time you press back stops reading as an occasion.
  final RxBool celebrating = false.obs;
  final TextEditingController feedback = TextEditingController();

  /// The matched coach. The backend will supply this once matching is real.
  Coach get coach => Coach.sample;

  String get coachName => coach.name;

  /// The date chosen in the "Schedule for later" sheet, if any.
  final Rxn<DateTime> scheduledFor = Rxn<DateTime>();

  /// The month the calendar sheet is showing. The design prints June 2024.
  final Rx<DateTime> calendarMonth = DateTime(2024, 6).obs;

  Timer? _timer;

  /// How long the filled stars stay on screen before the review opens.
  ///
  /// Tapping used to swap the screen in the same frame, so the star never
  /// appeared to fill — the tap read as "nothing happened, then a different
  /// screen". Exposed so a test can pump exactly this long.
  static const Duration ratingHold = Duration(milliseconds: 650);

  Timer? _ratingHold;

  @override
  void onInit() {
    super.onInit();
    _runMatching();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _ratingHold?.cancel();
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
        celebrating.value = true;
        stage.value = BookingStage.matched;
      }
    });
  }

  /// The burst has finished; the screen is now the plain matched frame.
  void celebrationShown() => celebrating.value = false;

  /// "Book a session" — the instructor screen's only action now.
  ///
  /// It used to be a pair: "Get started", which jumped straight to the
  /// communication picker, and "Schedule for later", which raised the date
  /// sheet. The design replaced both with one button that runs the booking
  /// properly — payment, then the calendar, then a confirmation.
  Future<void> bookSession() async {
    await Get.toNamed(AppRoutes.bookingPayment, arguments: offering);
  }

  /// Opens the communication picker, and from there the call.
  ///
  /// No longer reached from the matched screen — booking now goes through
  /// payment and a calendar instead. The picker, the call and the rating are
  /// still drawn (`Communiction method/selected` 280:26514 onward); this is
  /// where the flow resumes when a booked session actually starts, and it is
  /// kept so those stages stay reachable.
  void startSession() => stage.value = BookingStage.method;

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
    // Restarted on every tap: changing the answer before the hold is up
    // should not shorten it, and must not queue a second move.
    _ratingHold?.cancel();
    _ratingHold = Timer(ratingHold, () {
      // Guarded: back() can leave the rating stage while this is pending.
      if (stage.value == BookingStage.rating) {
        stage.value = BookingStage.feedback;
      }
    });
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
        _ratingHold?.cancel();
        stage.value = BookingStage.call;
      case BookingStage.feedback:
        stage.value = BookingStage.rating;
    }
  }
}
