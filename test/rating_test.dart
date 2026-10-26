import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/app_export.dart';
import 'package:soothifyafrica/app/data/models/booked_session.dart';
import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/data/models/session_offering.dart';
import 'package:soothifyafrica/app/data/repositories/mock_booking_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/modules/user/booking/controller/booking_controller.dart';
import 'package:soothifyafrica/app/modules/user/media/controller/media_controller.dart';

/// Rating, both kinds.
///
/// Each half was written and left unconnected: the content endpoint and
/// [MediaController.rate] had no star to press, and the post-session screen
/// collected five stars and a review and sent neither.
void main() {
  // AppFeedback raises a GetX snackbar, which reaches for the binding even
  // in test mode.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  group('a piece of content', () {
    const item = MediaItem(
      id: '1',
      title: 'Serene Evenings',
      type: MediaType.audio,
      durationSeconds: 900,
      rating: 4.8,
    );

    test('the stars go to the server, and the average comes back', () async {
      final content = _RecordingContent();
      final c = MediaController(item, content, source: 'Top Picks for you');

      expect(c.myRating.value, 0, reason: 'nobody has rated it yet');
      await c.rate(5);

      expect(content.rated, [('1', 5)]);
      expect(c.myRating.value, 5);
      expect(c.rating.value, 5, reason: 'the new average the server returned');
      expect(c.sending.value, isFalse);
    });

    test('a refused rating puts the row back', () async {
      final content = _RecordingContent(fails: true);
      final c = MediaController(item, content, source: 'x');

      await c.rate(2);
      expect(c.myRating.value, 0,
          reason: 'a score that did not take must not be shown as kept');
      expect(c.rating.value, 4.8, reason: 'the average is untouched');
    });

    test('a second tap while one is in flight is ignored', () async {
      final content = _RecordingContent();
      final c = MediaController(item, content, source: 'x');

      final first = c.rate(4);
      await c.rate(1);
      await first;

      expect(content.rated, [('1', 4)]);
    });
  });

  group('a session', () {
    // Plain tests, not widget ones: these are the controller's own
    // decisions, and a fake clock cannot advance a repository's latency.
    setUp(() => Get.testMode = true);

    BookingController controller({
      String sessionId = '',
      MockBookingRepository? bookings,
    }) =>
        BookingController(
          offering: SessionOffering.therapy,
          startAt: BookingStage.feedback,
          sessionId: sessionId,
          bookings: bookings,
        );

    test('the stars and the words are filed against the session', () async {
      final bookings = _RecordingBookings();
      final c = controller(sessionId: '42', bookings: bookings);

      c.rate(5);
      c.feedback.text = 'It helped.';
      await c.post();

      expect(bookings.rated, [('42', 5, 'It helped.')]);
      expect(c.stage.value, BookingStage.thanks);
      expect(c.posting.value, isFalse);
    });

    test('with no session id the review still ends on thanks', () async {
      final bookings = _RecordingBookings();
      final c = controller(bookings: bookings);

      c.feedback.text = 'Lovely.';
      await c.post();

      // The in-app feed builds invites out of notification copy and carries
      // no id. Holding the user on the form would punish them for that.
      expect(bookings.rated, isEmpty);
      expect(c.stage.value, BookingStage.thanks);
    });

    test('a review that did not send keeps the screen', () async {
      final bookings = _RecordingBookings(fails: true);
      final c = controller(sessionId: '42', bookings: bookings);

      c.rate(3);
      c.feedback.text = 'Fine.';
      await c.post();

      expect(c.stage.value, BookingStage.feedback,
          reason: 'the button has to stay where it can be pressed again');
      expect(c.posting.value, isFalse);
    });

    test('an empty review is not sent at all', () async {
      final bookings = _RecordingBookings();
      final c = controller(sessionId: '42', bookings: bookings);

      await c.post();
      expect(bookings.rated, isEmpty);
      expect(c.stage.value, BookingStage.feedback);
    });
  });
}

class _RecordingContent extends MockContentRepository {
  _RecordingContent({this.fails = false});

  final bool fails;
  final List<(String, int)> rated = [];

  @override
  Future<double> rate(String id, int stars) async {
    rated.add((id, stars));
    if (fails) throw const NetworkException();
    return stars.toDouble();
  }
}

class _RecordingBookings extends MockBookingRepository {
  _RecordingBookings({this.fails = false});

  final bool fails;
  final List<(String, int, String)> rated = [];

  @override
  Future<BookedSession> rate(
    String sessionId,
    int stars, {
    String feedback = '',
  }) async {
    rated.add((sessionId, stars, feedback));
    if (fails) throw const NetworkException();
    return BookedSession(
      id: sessionId,
      discipline: 'therapy',
      expertName: 'Baraqhat',
      startsAt: DateTime(2026, 9, 28, 10),
      endsAt: DateTime(2026, 9, 28, 11),
      status: 'completed',
      priceNaira: 15000,
      rating: stars,
    );
  }
}
