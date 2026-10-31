import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/booked_session.dart';
import '../../../../data/models/coach.dart';
import '../../../../data/models/session_offering.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/repositories/kyc_repository.dart';

/// How the session is taken. The design offers exactly these two.
enum CallMode {
  phone('Phone call'),
  video('Video call');

  const CallMode(this.label);

  final String label;
}

/// Where the booking flow currently is — Figma 135:20803 onward.
enum BookingStage { matching, matched, method, call, rating, feedback, thanks }

/// What the booking route was opened with.
///
/// It used to take a bare [SessionOffering] and always begin at the matching
/// interstitial. Joining a booked session from the notification feed has to
/// enter at the call instead, so the stage travels with the offering.
class BookingEntry {
  const BookingEntry({
    required this.offering,
    required this.stage,
    this.mode,
    this.sessionId = '',
  });

  final SessionOffering offering;
  final BookingStage stage;

  /// The session being joined, so the stars at the end of it can be filed
  /// against it. Empty when the caller has no id — see SessionInvite.
  final String sessionId;

  /// Voice or video, where the caller already knows. The waiting room does:
  /// its camera toggle is the choice, made before the call opens. Null leaves
  /// it to [BookingController], which falls back to voice.
  final CallMode? mode;
}

/// Drives the booking flow after Schedule.
///
/// One controller rather than five routes: the frames share a header and run
/// strictly in order, and a back press should step back through the flow
/// rather than unwind a route stack the user never chose to build.
class BookingController extends GetxController {
  BookingController({
    Duration? matchDuration,
    this.offering,
    this.startAt,
    CallMode? startMode,
    String sessionId = '',
    BookingRepository? bookings,
    KycRepository? kyc,
  })  : _matchDuration = matchDuration ?? const Duration(seconds: 3),
        _startMode = startMode,
        _sessionId = sessionId,
        _bookings = bookings,
        _kyc = kyc;

  /// Which session the stars at the end belong to. Empty when the flow was
  /// entered without one, and then the review is kept on the device rather
  /// than filed against the wrong session.
  final String _sessionId;

  /// Who to match with. Optional: without it the screen shows the frame's
  /// own coach, which is what the goldens are drawn against and what the
  /// build with no backend has always shown.
  final BookingRepository? _bookings;

  /// The questionnaire, for the "Because you feel..." chips. Those are the
  /// client's own answers, not anything about the expert.
  final KycRepository? _kyc;

  /// How the call opens when the route is entered at [BookingStage.call].
  /// The picker is not in that path, so without this every joined session
  /// would open as a voice call.
  final CallMode? _startMode;

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

  late final Rx<BookingStage> stage = (startAt ?? BookingStage.matching).obs;

  /// Where to begin. Null means the matching interstitial, which is how every
  /// route into this screen behaved before sessions could be joined.
  final BookingStage? startAt;
  late final Rxn<CallMode> mode = Rxn<CallMode>(_startMode);
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

  /// Who the server matched, once it has answered.
  final Rxn<MatchedExpert> matched = Rxn<MatchedExpert>();

  /// The chips under "Because you feel...", from the questionnaire.
  final RxList<String> feelings = <String>[].obs;

  /// Nobody practises this at all. Different from "still looking": the
  /// screen has to say so rather than show a coach who does not exist.
  final RxBool nobodyAvailable = false.obs;

  /// The match could not be asked for at all -- a timeout, or the server
  /// refusing. Different from [nobodyAvailable], which is a real answer.
  ///
  /// It used to be swallowed: the screen then fell through to the frame's
  /// own coach and announced a match with somebody who does not exist,
  /// while the calendar behind it asked again, succeeded, and booked a
  /// real practitioner. The two screens disagreed about who you had been
  /// matched with.
  final RxBool matchFailed = false.obs;

  /// Whether the match is still being asked for.
  final RxBool stillMatching = true.obs;

  /// The matched coach, as the screen reads them.
  ///
  /// Falls back to the frame's own sample when there is no repository to
  /// ask -- the no-backend build, and the goldens.
  Coach get coach {
    final match = matched.value;
    if (match != null) return Coach.fromMatch(match, feelings: feelings);

    // The frame's own coach, and only where there is no server to ask --
    // the no-backend build and the goldens. With a server, showing this
    // would be presenting a name out of the design as a real person.
    return Coach.sample;
  }

  /// Whether [coach] is somebody the server actually named.
  bool get hasRealMatch => matched.value != null;

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

  /// Guards against pushing the call twice: `onInit` opens it, and a
  /// rebuild must not open a second.
  bool _openedTheCall = false;

  @override
  void onInit() {
    super.onInit();
    // Entering at the call means the session was already matched and paid
    // for; running the interstitial would walk it through matching again.
    if (stage.value == BookingStage.matching) {
      _runMatching();
    } else {
      // Entering further along: no match is being asked for, so the
      // matched screen must not sit on a spinner waiting for one.
      stillMatching.value = false;
    }

    // ...and entering at the call means opening the real one. This hung
    // off `chooseMode` alone, which is the old method-selection step the
    // flow no longer takes -- so arriving here from the waiting room drew
    // the mock screens instead of joining anything.
    if (stage.value == BookingStage.call) {
      // After the first frame: onInit runs while the controller is being
      // put, which is before there is a navigator to push onto.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => unawaited(openTheCall()));
    }
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
    // Asked while the bar is running, so the wait the frame draws is the
    // wait for the answer rather than three seconds of theatre followed by
    // a second one.
    unawaited(_findSomebody());

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

  /// Who the server has, and what the client said they are carrying.
  ///
  /// Both are best effort. A matching screen that errors instead of showing
  /// somebody is worse than one showing the frame's own coach, and the
  /// chips are decoration on a page whose point is the match.
  Future<void> _findSomebody() async {
    final bookings = _bookings;
    if (bookings == null) {
      // No server to ask: the frame's own coach is the answer here, and
      // leaving this true would spin forever on the no-backend build.
      stillMatching.value = false;
      return;
    }

    unawaited(_readTheQuestionnaire());
    matchFailed.value = false;
    stillMatching.value = true;
    try {
      final found = await bookings.match(
        discipline: offering?.id ?? SessionOffering.therapy.id,
      );
      matched.value = found;
      nobodyAvailable.value = found == null;
    } catch (error) {
      // Not silently any more. Whatever this screen shows next, it must
      // not be a coach nobody was matched with.
      Log.e('matching could not reach the server', error: error);
      matchFailed.value = true;
    } finally {
      stillMatching.value = false;
    }
  }

  /// Asks again, for the retry on the failure state.
  Future<void> matchAgain() => _findSomebody();

  Future<void> _readTheQuestionnaire() async {
    final kyc = _kyc;
    if (kyc == null) return;
    try {
      final answers = await kyc.savedAnswers();
      feelings.assignAll(
        (answers['concerns'] ?? const <String>{}).map(_feelingLabel),
      );
    } catch (_) {
      // Chips are not worth a message. Without them the block is simply
      // not drawn.
    }
  }

  /// The questionnaire stores "sleep_disorder"; the chip reads "Restless
  /// sleep". Shortened from the carousel's own wording, which is a sentence
  /// rather than a chip.
  static String _feelingLabel(String value) => switch (value) {
        'stress' => 'Stressed',
        'anxiety' => 'Anxious',
        'sleep_disorder' => 'Restless',
        'depression' => 'Drained',
        'exploring' => 'Curious',
        _ => value,
      };

  /// The burst has finished; the screen is now the plain matched frame.
  void celebrationShown() => celebrating.value = false;

  /// "Book a session" — the instructor screen's only action now.
  ///
  /// It used to be a pair: "Get started", which jumped straight to the
  /// communication picker, and "Schedule for later", which raised the date
  /// sheet. The design replaced both with one button that runs the booking
  /// properly — payment, then the calendar, then a confirmation.
  Future<void> bookSession() async {
    // The calendar first, then payment: you choose when the session runs and
    // pay for that, rather than paying for an unscheduled one and picking a
    // day off the receipt.
    await Get.toNamed(
      AppRoutes.bookingCalendar,
      // With the coach they were just shown, so the calendar offers that
      // person's hours rather than matching again and perhaps landing on
      // somebody else.
      arguments: CalendarArguments(
        offering: offering ?? SessionOffering.therapy,
        expertId: matched.value?.id ?? '',
      ),
    );
  }

  /// Opens the communication picker, and from there the call.
  ///
  /// No longer reached from the matched screen — booking now goes through
  /// payment and a calendar instead. The picker, the call and the rating are
  /// still drawn (`Communiction method/selected` 280:26514 onward); this is
  /// where the flow resumes when a booked session actually starts, and it is
  /// kept so those stages stay reachable.
  void startSession() => stage.value = BookingStage.method;

  /// "Schedule for later" — the sheet picks a day, and the calendar takes
  /// it from there.
  ///
  /// It used to say a session was set, which it never was: booking happens
  /// on the calendar screen, which holds the hour at the server and leads
  /// to payment. This hands the chosen day to it rather than inventing a
  /// booking nobody made.
  void schedule(DateTime date) {
    scheduledFor.value = date;
    Get.toNamed(
      AppRoutes.bookingCalendar,
      arguments: CalendarArguments(
        offering: offering ?? SessionOffering.therapy,
        expertId: matched.value?.id ?? '',
      ),
    );
  }

  void chooseMode(CallMode value) {
    mode.value = value;
    stage.value = BookingStage.call;
    unawaited(openTheCall());
  }

  /// Opens the real call, and moves to the rating when it ends.
  ///
  /// The stage below it stays what it was: the prebuilt call is pushed
  /// over this screen, so backing out of it lands here rather than on
  /// nothing. Without a session id there is nothing to join -- the mock
  /// screens still draw, which is what the no-backend build shows.
  Future<void> openTheCall() async {
    // Nothing to join: the build with no backend, and the goldens. The
    // drawn stage stands in for a call there, which is all it can do.
    if (_sessionId.isEmpty) {
      Log.e('the call stage was reached with no session to join');
      return;
    }
    if (_openedTheCall) return;      // one room, however many rebuilds
    _openedTheCall = true;

    await Get.toNamed(AppRoutes.sessionCall, arguments: _sessionId);
    // However it ended -- hung up, refused, or backed out of -- the next
    // thing the flow asks is how it went.
    if (stage.value == BookingStage.call) endCall();
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

  /// True while the review is in flight, so a second tap cannot send it
  /// twice.
  final RxBool posting = false.obs;

  /// Posting the review ends on its own success screen rather than dropping
  /// the user back on the dashboard with a toast — the same acknowledgement
  /// the booking chain ends with, so finishing a session reads like finishing
  /// one.
  ///
  /// The stars and the words go to the server together: the frame asks for
  /// the rating first and the review after, but they are one answer about
  /// one session. They used to go nowhere at all — this screen collected
  /// both and advanced, while the endpoint and the repository call sat
  /// written and unused.
  Future<void> post() async {
    if (!canPost || posting.value) return;

    final bookings = _bookings;
    if (_sessionId.isEmpty || bookings == null) {
      // Nothing to file it against: the in-app feed builds its invites out
      // of notification copy and carries no session id. Keeping the user
      // here would punish them for that, so the thanks screen still shows.
      stage.value = BookingStage.thanks;
      return;
    }

    posting.value = true;
    try {
      await bookings.rate(
        _sessionId,
        rating.value,
        feedback: feedback.text.trim(),
      );
      stage.value = BookingStage.thanks;
    } on AppException catch (e) {
      // Said, not swallowed: a review that did not reach the expert is
      // worth knowing about, and the button stays where it was so it can
      // be pressed again.
      AppFeedback.error(e);
    } finally {
      posting.value = false;
    }
  }

  /// The success screen's countdown has run out.
  void leaveThanks() =>
      Get.until((route) => Get.currentRoute == AppRoutes.shell);

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
      // The review is posted; there is nothing behind this but a form that
      // would post it again.
      case BookingStage.thanks:
        leaveThanks();
    }
  }
}
