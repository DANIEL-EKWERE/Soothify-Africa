import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:soothifyafrica/app/data/models/app_notification.dart';
import 'package:soothifyafrica/app/data/models/booked_session.dart';
import 'package:soothifyafrica/app/data/models/expert_session.dart';
import 'package:soothifyafrica/app/data/models/session_invite.dart';
import 'package:soothifyafrica/app/data/repositories/booking_repository.dart';
import 'package:soothifyafrica/app/modules/practitioner/call/controller/joining_session_controller.dart';
import 'package:soothifyafrica/app/modules/user/session/controller/client_joining_controller.dart';

/// The whole way from a feed row to the call, link by link.
///
/// Each link was built and the chain still did not work, because the first
/// one was missing: the server sends `target`, the app dropped it, so a
/// session row carried no session id. Everything after it then behaved as
/// though the session were unknown -- the waiting room could not tell
/// whether it was time, and the call fell through to the drawn stage.
///
/// Tested as a chain for that reason. A test per link passes while the
/// chain is broken.
class _Bookings implements BookingRepository {
  _Bookings(this._sessions);

  final List<BookedSession> _sessions;

  @override
  Future<List<BookedSession>> mySessions({bool upcomingOnly = false}) async =>
      _sessions;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

/// What the server actually serves for a booking notification.
Map<String, dynamic> serverRow({String target = 'session/2'}) => {
      'id': 7,
      'kind': 'booking',
      'title': 'Booking',
      'body': 'You have a Yoga session on 28 Nov 2026 at 5:00pm',
      'emphasis': 'Yoga',
      'target': target,
      'filters': ['sessions'],
      'unread': true,
      'created_at': '2026-11-02T10:00:00Z',
    };

BookedSession sessionAt(DateTime starts) => BookedSession(
      id: '2',
      discipline: 'yoga',
      expertName: 'John Doe',
      startsAt: starts,
      endsAt: starts.add(const Duration(minutes: 50)),
      status: 'confirmed',
      priceNaira: 25000,
    );

void main() {
  _practitionerSide();
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime(2026, 11, 2, 12);

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  test('link 1: the row carries the session the server named', () {
    final row = AppNotification.fromJson(serverRow());

    expect(row.target, 'session/2', reason: 'the target was dropped');
    expect(row.sessionId, '2');
  });

  test('link 1: a row about nothing in particular has no session', () {
    expect(AppNotification.fromJson(serverRow(target: 'breathe')).sessionId, '');
    expect(AppNotification.fromJson(serverRow(target: '')).sessionId, '');
  });

  test('link 2: reading the row keeps its session', () {
    final read = AppNotification.fromJson(serverRow()).markedRead();

    expect(read.sessionId, '2', reason: 'reading it forgot the session');
  });

  test('link 3: the waiting room knows which session, and refuses early',
      () async {
    final row = AppNotification.fromJson(serverRow());

    final controller = ClientJoiningController(
      bookings: _Bookings([sessionAt(now.add(const Duration(days: 3)))]),
      now: () => now,
      invite: SessionInvite(
        expertName: 'John',
        service: '1-on-1 Yoga',
        time: '5:00pm',
        date: 'Nov 5 2026',
        // Exactly what the feed hands it.
        sessionId: row.sessionId,
      ),
    )..onInit();
    await controller.ready;

    expect(controller.canJoin, isFalse,
        reason: 'a session three days away was joinable');
    expect(controller.waitLabel, 'This session is in 3 days.');
  });

  test('link 3: and lets you in once it is time', () async {
    final row = AppNotification.fromJson(serverRow());

    final controller = ClientJoiningController(
      bookings: _Bookings([sessionAt(now.add(const Duration(minutes: 5)))]),
      now: () => now,
      invite: SessionInvite(
        expertName: 'John',
        service: '1-on-1 Yoga',
        time: '5:00pm',
        date: 'Nov 2 2026',
        sessionId: row.sessionId,
      ),
    )..onInit();
    await controller.ready;

    expect(controller.canJoin, isTrue);
  });
}

/// The practitioner's side of the same thing.
///
/// Their screen had no "Join" at all -- the frame draws none, and that was
/// taken to mean the screen *was* the joining. Nothing advanced it, so a
/// practitioner sat on a pulsing circle for ever.
void _practitionerSide() {
  final now = DateTime(2026, 11, 2, 12);

  ExpertSession theirSession(DateTime starts) => ExpertSession(
        id: '2',
        clientName: 'Ada Obi',
        service: '1-on-1 Yoga',
        startsAt: starts,
        endsAt: starts.add(const Duration(minutes: 50)),
      );

  test('a session days away cannot be entered', () {
    final c = JoiningSessionController(
      session: theirSession(now.add(const Duration(days: 3))),
      now: () => now,
    );

    expect(c.canJoin, isFalse);
    expect(c.waitLabel, 'This session is in 3 days.');
  });

  test('fifteen minutes before, the room opens', () {
    final c = JoiningSessionController(
      session: theirSession(now.add(const Duration(minutes: 14))),
      now: () => now,
    );

    // Earlier than the client's ten, so the coach is there first.
    expect(c.canJoin, isTrue);
    expect(c.waitLabel, isEmpty);
  });

  test('sixteen minutes before, it does not', () {
    final c = JoiningSessionController(
      session: theirSession(now.add(const Duration(minutes: 16))),
      now: () => now,
    );

    expect(c.canJoin, isFalse);
    expect(c.waitLabel, contains('fifteen minutes'));
  });

  test('once it has ended it is closed', () {
    final c = JoiningSessionController(
      session: theirSession(now.subtract(const Duration(hours: 2))),
      now: () => now,
    );

    expect(c.canJoin, isFalse);
    expect(c.waitLabel, 'This session has ended.');
  });

  test('no session is said plainly, not spun on', () {
    final c = JoiningSessionController(session: null, now: () => now);

    expect(c.canJoin, isFalse);
    expect(c.waitLabel, isNotEmpty);
  });
}
