import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:soothifyafrica/app/data/models/booked_session.dart';
import 'package:soothifyafrica/app/data/models/session_invite.dart';
import 'package:soothifyafrica/app/data/repositories/booking_repository.dart';
import 'package:soothifyafrica/app/modules/user/session/controller/client_joining_controller.dart';

/// Joining a session before its time.
///
/// Nothing checked the clock: any session row opened the waiting room and
/// the call began four seconds later, whatever day the session was booked
/// for. The gate alone was not enough either — the countdown raced the
/// lookup, and the gate allows when it cannot tell which session this is.
class _SlowBookings implements BookingRepository {
  _SlowBookings(this._sessions, {this.delay = const Duration(seconds: 2)});

  final List<BookedSession> _sessions;

  /// Longer than the waiting room's countdown, which is the race.
  final Duration delay;

  @override
  Future<List<BookedSession>> mySessions({bool upcomingOnly = false}) async {
    await Future<void>.delayed(delay);
    return _sessions;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

BookedSession sessionAt(DateTime starts, {String id = '8'}) => BookedSession(
      id: id,
      discipline: 'therapy',
      expertName: 'Baraqhat Ibrahim',
      startsAt: starts,
      endsAt: starts.add(const Duration(minutes: 50)),
      status: 'confirmed',
      priceNaira: 25000,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime(2026, 11, 2, 12);
  DateTime fixedNow() => now;

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  Future<ClientJoiningController> open(
    BookedSession session, {
    String id = '8',
  }) async {
    final controller = ClientJoiningController(
      bookings: _SlowBookings([session]),
      now: fixedNow,
      invite: SessionInvite(
        expertName: 'Baraqhat',
        service: '1-on-1 Therapy',
        time: '12:00 PM',
        date: 'Nov 2 2026',
        sessionId: id,
      ),
    )..onInit();
    await controller.ready;
    return controller;
  }

  test('a session days away cannot be joined', () async {
    final controller = await open(
      sessionAt(now.add(const Duration(days: 3))),
    );

    expect(controller.canJoin, isFalse);
    expect(controller.waitLabel, 'This session is in 3 days.');
  });

  test('a session later today cannot be joined yet', () async {
    final controller = await open(
      sessionAt(now.add(const Duration(hours: 2))),
    );

    expect(controller.canJoin, isFalse);
    expect(controller.waitLabel, 'This session starts in 2 hours.');
  });

  test('ten minutes before, it opens', () async {
    final controller = await open(
      sessionAt(now.add(const Duration(minutes: 9))),
    );

    expect(controller.canJoin, isTrue);
  });

  test('eleven minutes before, it does not', () async {
    final controller = await open(
      sessionAt(now.add(const Duration(minutes: 11))),
    );

    expect(controller.canJoin, isFalse);
    expect(controller.waitLabel, contains('ten minutes before'));
  });

  test('during the session it is open', () async {
    final controller = await open(
      sessionAt(now.subtract(const Duration(minutes: 20))),
    );

    expect(controller.canJoin, isTrue);
  });

  test('once it has ended it is closed', () async {
    final controller = await open(
      sessionAt(now.subtract(const Duration(hours: 2))),
    );

    expect(controller.canJoin, isFalse);
    expect(controller.waitLabel, 'This session has ended.');
  });

  test('the lookup is awaited, not raced', () async {
    // The bug: the waiting room counted down four seconds and joined,
    // while the lookup took longer. `ready` is what the screen waits on.
    final controller = ClientJoiningController(
      bookings: _SlowBookings(
        [sessionAt(now.add(const Duration(days: 3)))],
        delay: const Duration(seconds: 5),
      ),
      now: fixedNow,
      invite: const SessionInvite(
        expertName: 'Baraqhat',
        service: '1-on-1 Therapy',
        time: '12:00 PM',
        date: 'Nov 2 2026',
        sessionId: '8',
      ),
    )..onInit();

    // Before the answer lands it cannot tell, and says so by allowing.
    expect(controller.canJoin, isTrue);

    await controller.ready;

    // Once it knows, it refuses — which is why the screen must wait.
    expect(controller.canJoin, isFalse);
  });
}
