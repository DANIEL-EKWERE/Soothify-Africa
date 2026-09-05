import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/wellness_kyc.dart';
import 'package:soothifyafrica/app/modules/user/booking/booking_screen.dart';
import 'package:soothifyafrica/app/modules/user/booking/controller/booking_controller.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/booking_test.dart
const _art = [
  'assets/images/coach/photo.png',
  'assets/images/coach/video.png',
  'assets/images/coach/peer_1.png',
  'assets/images/coach/peer_2.png',
  'assets/images/coach/peer_3.png',
  'assets/images/coach/peer_4.png',
  'assets/images/coach/call_avatar.png',
];

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  BookingController boot() => Get.put(
        BookingController(matchDuration: const Duration(milliseconds: 300)),
      );

  testWidgets('matching advances to the communication method', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = boot();

    await pumpScreen(tester, const BookingScreen());
    expect(c.stage.value, BookingStage.matching);
    expect(find.textContaining('Pairing you with a wellness coach'),
        findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // Matching lands on the coach profile; the method picker comes after
    // "Get started".
    expect(c.stage.value, BookingStage.matched);
    expect(find.text('Awesome! You matched with'), findsOneWidget);
    expect(find.text('98% Match'), findsOneWidget);

    c.getStarted();
    await tester.pumpAndSettle();
    expect(find.text('Phone call'), findsOneWidget);
    expect(find.text('Video call'), findsOneWidget);
  });

  testWidgets('the flow runs method -> call -> rating -> feedback',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = boot();

    await pumpScreen(tester, const BookingScreen());
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    c.getStarted();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Phone call'));
    await tester.pumpAndSettle();
    expect(c.stage.value, BookingStage.call);
    expect(c.mode.value, CallMode.phone);
    expect(find.text('Baraqhat Ibrahim'), findsOneWidget);

    c.endCall();
    await tester.pumpAndSettle();
    expect(c.stage.value, BookingStage.rating);

    c.rate(4);
    await tester.pumpAndSettle();
    expect(c.rating.value, 4);
    expect(c.stage.value, BookingStage.feedback);
    expect(find.text('Post'), findsOneWidget);
  });

  testWidgets('back retraces the flow rather than leaving it', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = boot();

    await pumpScreen(tester, const BookingScreen());
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    c.getStarted();
    c.chooseMode(CallMode.video);
    expect(c.stage.value, BookingStage.call);

    c.back();
    expect(c.stage.value, BookingStage.method);
    c.back();
    // Back from the method picker returns to the profile rather than leaving.
    expect(c.stage.value, BookingStage.matched);
  });

  testWidgets('an empty note cannot be posted', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = boot();

    await pumpScreen(tester, const BookingScreen());
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    c.getStarted();
    c.chooseMode(CallMode.phone);
    c.endCall();
    c.rate(5);
    await tester.pumpAndSettle();

    expect(c.canPost, isFalse);
    await tester.enterText(find.byType(TextField), '  ');
    expect(c.canPost, isFalse);
    await tester.enterText(find.byType(TextField), 'It went well');
    expect(c.canPost, isTrue);
  });

  test('Schedule is gated by its own questionnaire, not Meditation\'s', () {
    // Completing Meditation must not let Schedule skip its questions.
    expect(WellnessTrack.schedule.prefKey, isNot(WellnessTrack.meditation.prefKey));
  });

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('booking matching, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      boot();

      await pumpScreen(tester, const BookingScreen(), brightness: brightness);
      await tester.pump(const Duration(milliseconds: 150));

      await expectLater(find.byType(BookingScreen),
          matchesGoldenFile('goldens/booking_matching_$name.png'));

      // The interstitial runs a periodic timer; letting it finish stops it
      // outliving the tree, which fails the test after the golden is taken.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
    });
  }

  testWidgets('the coach profile shows the matched detail', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = boot();

    await pumpScreen(tester, const BookingScreen());
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await precacheAll(tester, find.byType(BookingScreen), _art);

    expect(c.stage.value, BookingStage.matched);
    expect(find.text('Baraqhat Ibrahim'), findsOneWidget);
    expect(find.text('98% Match'), findsOneWidget);

    // The frame is 1677 tall, so the ListView has not built the lower half
    // yet — the rest has to be scrolled to before it exists at all.
    await expectLater(find.byType(BookingScreen),
        matchesGoldenFile('goldens/booking_matched.png'));

    // Each is checked where it becomes visible: the list disposes what
    // scrolls away, so asserting everything after one long scroll finds only
    // whatever happens to be on screen at the end.
    //
    // dragUntilVisible rather than scrollUntilVisible — the profile also
    // holds a horizontal video row, so the scrollable must be named.
    final page = find.byType(ListView).first;
    for (final label in const [
      'Other Instructors Matches',
      'Get started',
      'Schedule for later',
    ]) {
      await tester.dragUntilVisible(
        find.text(label),
        page,
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      expect(find.text(label), findsOneWidget, reason: '$label is missing');
    }
  });

  testWidgets('booking method', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    boot();

    await pumpScreen(tester, const BookingScreen());
    await tester.pump(const Duration(milliseconds: 400));
    Get.find<BookingController>().getStarted();
    await tester.pumpAndSettle();

    await expectLater(find.byType(BookingScreen),
        matchesGoldenFile('goldens/booking_method.png'));
  });

  testWidgets('booking rating', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = boot();

    await pumpScreen(tester, const BookingScreen());
    await tester.pump(const Duration(milliseconds: 400));
    c.getStarted();
    c.chooseMode(CallMode.phone);
    c.endCall();
    await tester.pumpAndSettle();

    await expectLater(find.byType(BookingScreen),
        matchesGoldenFile('goldens/booking_rating.png'));
  });
}
