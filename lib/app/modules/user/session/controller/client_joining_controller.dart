import '../../../../core/app_export.dart';
import '../../../../data/models/booked_session.dart';
import '../../../../data/models/session_invite.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/models/session_offering.dart';
import '../../booking/controller/booking_controller.dart';

/// Drives the client's side of joining a booked session — Figma `280:26643`.
///
/// The practitioner has its own screen and controller; this one shows the
/// *expert's* details rather than the client's, and its Cancel is outlined
/// rather than filled.
class ClientJoiningController extends GetxController {
  ClientJoiningController({
    String? expertName,
    String? service,
    String? time,
    String? date,
    this.connecting = const Duration(seconds: 4),
    BookingRepository? bookings,
    DateTime Function()? now,
    SessionInvite? invite,
  })  : _bookings = bookings,
        _now = now ?? DateTime.now,
        // Passed directly by a test, which has no way to set
        // `Get.arguments`; the route supplies it in the app.
        _invite = invite ??
            (Get.arguments is SessionInvite
                ? Get.arguments as SessionInvite
                : null),
        _expertName = expertName,
        _service = service,
        _time = time,
        _date = date;

  /// The session tapped in the feed, when the screen was opened from there.
  final SessionInvite? _invite;

  /// Looked up so the screen knows when the session actually is. Optional
  /// so a golden can build this without one.
  final BookingRepository? _bookings;

  /// Injectable, because everything below turns on what time it is.
  final DateTime Function() _now;

  /// The booked session this screen is about, once it has been found.
  final Rxn<BookedSession> session = Rxn<BookedSession>();

  /// How early somebody may go in. Early enough to be waiting when the
  /// coach arrives, not so early that a session booked for Friday can be
  /// joined on Tuesday.
  static const openFrom = Duration(minutes: 10);

  @override
  void onInit() {
    super.onInit();
    ready = _findTheSession();
  }

  /// The lookup, so the screen can wait for it before deciding.
  ///
  /// Without this the waiting room's countdown raced it: four seconds
  /// passed, the session was not known yet, and [canJoin] -- which allows
  /// when it cannot tell -- let the call open whatever day it was booked
  /// for.
  late final Future<void> ready;

  Future<void> _findTheSession() async {
    final id = _invite?.sessionId ?? '';
    final bookings = _bookings;
    if (id.isEmpty || bookings == null) return;

    try {
      final mine = await bookings.mySessions();
      session.value = mine.firstWhereOrNull((s) => s.id == id);
    } catch (error) {
      // Without it the screen still shows; it simply cannot say when.
      Log.e('could not read the session being joined', error: error);
    }
  }

  /// Whether the call may be entered yet.
  ///
  /// True when the session is unknown: the feed can open this screen from
  /// a row that carries no id, and refusing on a guess would lock
  /// somebody out of a session that is happening.
  bool get canJoin {
    final booked = session.value;
    if (booked == null) return true;

    final now = _now();
    return !now.isBefore(booked.startsAt.subtract(openFrom)) &&
        now.isBefore(booked.endsAt);
  }

  /// Why it cannot be joined, for the line under the button.
  String get waitLabel {
    final booked = session.value;
    if (booked == null || canJoin) return '';

    final now = _now();
    if (!now.isBefore(booked.endsAt)) return 'This session has ended.';

    final until = booked.startsAt.difference(now);
    if (until.inDays >= 1) {
      final days = until.inDays;
      return 'This session is in $days ${days == 1 ? 'day' : 'days'}.';
    }
    if (until.inHours >= 1) {
      final hours = until.inHours;
      return 'This session starts in $hours ${hours == 1 ? 'hour' : 'hours'}.';
    }
    return 'You can join ten minutes before it starts.';
  }

  final String? _expertName;
  final String? _service;
  final String? _time;
  final String? _date;

  /// How long "Joining Call" holds before the call opens. The screen owns the
  /// countdown — it is what the user is waiting on — and this is injectable so
  /// a test does not sit through a real four seconds.
  final Duration connecting;

  String get expertName => _expertName ?? _invite?.expertName ?? 'Baraqhat';
  String get service => _service ?? _invite?.service ?? '1-on-1 Therapy';
  String get time => _time ?? _invite?.time ?? '10:00 AM - 11:00 AM';
  String get date => _date ?? _invite?.date ?? 'Sep 28 2026';

  final RxBool micOn = true.obs;
  final RxBool cameraOn = true.obs;

  void toggleMic() => micOn.value = !micOn.value;

  void toggleCamera() => cameraOn.value = !cameraOn.value;

  /// Into the call itself, replacing the waiting room so Cancel inside the
  /// call does not step back onto it.
  ///
  /// The camera toggle above is the choice between a voice call and a video
  /// one — the same bargain every pre-join screen offers. Nothing else in the
  /// flow asks: the communication picker the design draws sits on a branch
  /// that booking no longer takes.
  void join() {
    // Not before its time. Nothing checked, so any session row opened the
    // waiting room and the call started four seconds later -- whatever
    // day the session was actually booked for.
    if (!canJoin) {
      AppFeedback.info(waitLabel);
      return;
    }

    Get.offNamed(
      AppRoutes.booking,
      arguments: BookingEntry(
        offering: _invite?.offering ?? SessionOffering.therapy,
        stage: BookingStage.call,
        mode: cameraOn.value ? CallMode.video : CallMode.phone,
        sessionId: _invite?.sessionId ?? '',
      ),
    );
  }

  void cancel() => Get.back();
}
