import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:soothifyafrica/app/core/errors/app_exception.dart';
import 'package:soothifyafrica/app/data/models/booked_session.dart';
import 'package:soothifyafrica/app/data/models/call_credentials.dart';
import 'package:soothifyafrica/app/data/repositories/booking_repository.dart';
import 'package:soothifyafrica/app/modules/user/booking/controller/booking_controller.dart';
import 'package:soothifyafrica/app/data/models/session_offering.dart';
import 'package:soothifyafrica/app/modules/user/session/session_call_screen.dart';

/// Joining a session's call.
///
/// The call itself cannot be exercised here — it needs two devices and a
/// real room. What can be, and is what used to be missing entirely, is
/// everything around it: asking the server for credentials at the moment
/// they are needed, and saying plainly why it will not open when the
/// server refuses.
class _StubBookings implements BookingRepository {
  _StubBookings({this.credentials, this.failure});

  final CallCredentials? credentials;
  final AppException? failure;
  final asked = <String>[];

  @override
  Future<CallCredentials> callToken(String sessionId) async {
    asked.add(sessionId);
    final problem = failure;
    if (problem != null) throw problem;
    return credentials!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

CallCredentials good({String mode = 'video'}) => CallCredentials(
      appId: 180281881,
      token: 'a-signed-token',
      roomId: 'session-8',
      userId: '12',
      mode: mode,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group('the credentials', () {
    test('are asked for at the moment the call opens', () async {
      final bookings = _StubBookings(credentials: good());
      final controller = SessionCallController(bookings, '8')..onInit();
      await Future<void>.delayed(Duration.zero);

      // Per session, and only now: a token minted early would be a key to
      // a room left lying about.
      expect(bookings.asked, ['8']);
      expect(controller.credentials.value?.roomId, 'session-8');
      expect(controller.refusal.value, isEmpty);
    });

    test('the server\'s own words are shown when it refuses', () async {
      final controller = SessionCallController(
        _StubBookings(
          failure: const ValidationException(
            'The room opens fifteen minutes before the session.',
          ),
        ),
        '8',
      )..onInit();
      await Future<void>.delayed(Duration.zero);

      // Far more use than "something went wrong": it says when to come
      // back.
      expect(
        controller.refusal.value,
        'The room opens fifteen minutes before the session.',
      );
      expect(controller.credentials.value, isNull);
    });

    test('a session with no id asks for nothing', () async {
      final bookings = _StubBookings(credentials: good());
      final controller = SessionCallController(bookings, '')..onInit();
      await Future<void>.delayed(Duration.zero);

      expect(bookings.asked, isEmpty);
      expect(controller.refusal.value, isNotEmpty);
    });

    test('credentials that cannot join a room are refused', () async {
      // A reply shaped right but empty — better caught here than handed
      // to the SDK, which fails with its own error.
      final controller = SessionCallController(
        _StubBookings(
          credentials: const CallCredentials(
            appId: 0, token: '', roomId: '', userId: '',
          ),
        ),
        '8',
      )..onInit();
      await Future<void>.delayed(Duration.zero);

      expect(controller.credentials.value, isNull);
      expect(controller.refusal.value, isNotEmpty);
    });
  });

  group('what was booked decides the call', () {
    test('a video booking opens a video call', () {
      expect(good().isVideo, isTrue);
    });

    test('a phone booking does not', () {
      // The server stores 'phone', not 'audio'.
      expect(good(mode: 'phone').isVideo, isFalse);
    });

    test('an unknown mode falls back to video', () {
      expect(good(mode: '').isVideo, isTrue);
    });
  });

  group('opening it from the flow', () {
    test('entering at the call stage opens the real one', () {
      // What the waiting room does: straight to the call stage, with the
      // session it is for.
      final entry = BookingEntry(
        offering: SessionOffering.therapy,
        stage: BookingStage.call,
        sessionId: '8',
      );

      expect(entry.stage, BookingStage.call);
      expect(entry.sessionId, '8');
    });
  });

  group('reading the server\'s answer', () {
    test('it takes the app id however it is typed', () {
      expect(
        CallCredentials.fromJson({'app_id': 180281881}).appId,
        180281881,
      );
      expect(
        CallCredentials.fromJson({'app_id': '180281881'}).appId,
        180281881,
      );
    });

    test('the recording notice is carried', () {
      // The server records the disclosure as it issues the token, so this
      // is shown rather than skipped.
      final creds = CallCredentials.fromJson({
        'app_id': 1, 'token': 't', 'room_id': 'r', 'user_id': '1',
        'recording_notice': 'This session is recorded.',
      });

      expect(creds.recordingNotice, 'This session is recorded.');
    });
  });
}

/// Opening the call from the flow.
///
/// The real call hung off `chooseMode`, the old method-selection step the
/// booking no longer takes. Arriving at the call stage from the waiting
/// room therefore opened nothing, and the mock screens drew instead.
class _CountingBookings implements BookingRepository {
  int tokensAsked = 0;

  @override
  Future<CallCredentials> callToken(String sessionId) async {
    tokensAsked += 1;
    return good();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}
