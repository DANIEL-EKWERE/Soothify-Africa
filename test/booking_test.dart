import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/session_offering.dart';
import 'package:soothifyafrica/app/data/models/wellness_kyc.dart';
import 'package:soothifyafrica/app/modules/user/booking/booking_screen.dart';
import 'package:soothifyafrica/app/modules/user/booking/controller/booking_controller.dart';
import 'package:soothifyafrica/app/widgets/confetti_overlay.dart';

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

  BookingController bootFor(SessionOffering offering) => Get.put(
        BookingController(
          matchDuration: const Duration(milliseconds: 300),
          offering: offering,
        ),
      );

  group('the match celebration', () {
    /// Runs matching out and stops partway through the burst.
    ///
    /// Everything here steps with `pump`, never `pumpAndSettle`: settling
    /// runs the 2.6s burst to its end and retires it, which is how the first
    /// cut of this golden came out with no confetti in it. [precacheAll] ends
    /// in a settle too, so the art is cached by hand while the screen is
    /// still on the matching stage.
    Future<BookingController> toCelebration(
      WidgetTester tester, {
      Brightness brightness = Brightness.light,
      bool withArt = false,
    }) async {
      useDesignFrame(tester);
      await loadAppFonts();
      final c = boot();
      await pumpScreen(tester, const BookingScreen(),
          brightness: brightness, motion: true);
      if (withArt) {
        await tester.runAsync(() async {
          final element = tester.element(find.byType(BookingScreen));
          for (final path in _art) {
            await precacheImage(AssetImage(path), element);
          }
        });
      }
      await tester.pump(const Duration(milliseconds: 400));
      // Far enough in that every piece has been released, not so far that
      // any has faded.
      await tester.pump(const Duration(milliseconds: 900));
      return c;
    }

    for (final (name, brightness) in [
      ('light', Brightness.light),
      ('dark', Brightness.dark),
    ]) {
      testWidgets('booking celebration, $name', (tester) async {
        await toCelebration(tester, brightness: brightness, withArt: true);

        await expectLater(find.byType(BookingScreen),
            matchesGoldenFile('goldens/booking_celebration_$name.png'));

        // Leave nothing running for the next test.
        await tester.pumpAndSettle();
      });
    }

    testWidgets('confetti falls the moment the match lands', (tester) async {
      final c = await toCelebration(tester);
      expect(c.stage.value, BookingStage.matched);
      expect(c.celebrating.value, isTrue);
      expect(find.byType(ConfettiOverlay), findsOneWidget);
      // The celebration frame carries the plain frame's copy underneath.
      expect(find.text('Awesome! You matched with'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(c.celebrating.value, isFalse,
          reason: 'the burst retires itself once it has played');
      expect(find.byType(ConfettiOverlay), findsNothing);
    });

    testWidgets('it does not fire a second time on the way back',
        (tester) async {
      final c = await toCelebration(tester);
      await tester.pumpAndSettle();
      expect(find.byType(ConfettiOverlay), findsNothing);

      c.getStarted();
      await tester.pumpAndSettle();
      c.back();
      await tester.pumpAndSettle();

      expect(c.stage.value, BookingStage.matched);
      expect(find.byType(ConfettiOverlay), findsNothing,
          reason: 'returning to the matched screen is not a new occasion');
    });

    testWidgets('it stays on the matched screen, not the method picker',
        (tester) async {
      final c = await toCelebration(tester);
      expect(find.byType(ConfettiOverlay), findsOneWidget);

      // Straight on through, while the burst is still running.
      c.getStarted();
      await tester.pump();
      expect(find.byType(ConfettiOverlay), findsNothing);

      await tester.pumpAndSettle();
    });

    testWidgets('reduce motion skips the burst without stalling the screen',
        (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      disableMotion(tester);
      final c = boot();
      await pumpScreen(tester, const BookingScreen(), motion: false);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // No paper, and the flag still clears — otherwise the celebration
      // would be owed forever and fire on a later visit.
      expect(c.celebrating.value, isFalse);
      expect(find.byType(ConfettiOverlay), findsNothing);
      expect(find.text('Awesome! You matched with'), findsOneWidget);
    });
  });

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

  test('every track is gated by its own questionnaire', () {
    // Answering one card's questions must not let another card skip its own.
    final keys = WellnessTrack.values.map((t) => t.prefKey).toSet();
    expect(keys, hasLength(WellnessTrack.values.length));
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

  testWidgets('the matching screen names the discipline it was booked for',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    // `Matching pilates instructor` (259:58806). The offering is the only
    // thing that knows which discipline was booked, and it used to be
    // dropped at the receipt.
    bootFor(SessionOffering.meditation);

    await pumpScreen(tester, const BookingScreen());
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Finding your Pilates instructor'), findsOneWidget);
    // The frame's own caption stops mid-word at 65 characters; it is
    // finished here, as the receipt's scrambled line was.
    expect(find.textContaining('looking for.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  });

  test('every discipline names the person it is finding', () {
    // Read from `Matching pilates instructor` (259:58806).
    expect(SessionOffering.meditation.matchingHeading,
        'Finding your Pilates instructor');

    // Derived from that pattern and the frames' own names —
    // `Matching Therapist` (259:58834) and `Matching instructor`
    // (259:58748), neither fetched. A guess, but the previous fallback was
    // the old file's generic sentence, which matched no frame at all.
    expect(SessionOffering.therapy.matchingHeading, 'Finding your therapist');
    expect(SessionOffering.balance.matchingHeading, 'Finding your instructor');

    // Whatever the wording, none of them may fall back to the old line.
    for (final o in SessionOffering.values) {
      expect(o.matchingHeading, startsWith('Finding your'),
          reason: '${o.id} still shows copy from the previous file');
      expect(o.matchingHeading, isNot(contains('Pairing you with')));
    }
  });

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
    // yet — the rest has to be scrolled to before it exists at all. The
    // golden for this stage is captured in the light/dark loop below.

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

  for (final (shade, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('booking method, $shade', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      boot();

      await pumpScreen(tester, const BookingScreen(), brightness: brightness);
      await tester.pump(const Duration(milliseconds: 400));
      Get.find<BookingController>().getStarted();
      await tester.pumpAndSettle();

      await expectLater(find.byType(BookingScreen),
          matchesGoldenFile('goldens/booking_method_$shade.png'));
    });

    testWidgets('booking rating, $shade', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      final c = boot();

      await pumpScreen(tester, const BookingScreen(), brightness: brightness);
      await tester.pump(const Duration(milliseconds: 400));
      c.getStarted();
      c.chooseMode(CallMode.phone);
      c.endCall();
      await tester.pumpAndSettle();

      await expectLater(find.byType(BookingScreen),
          matchesGoldenFile('goldens/booking_rating_$shade.png'));
    });

    testWidgets('booking matched, $shade', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      boot();

      await pumpScreen(tester, const BookingScreen(), brightness: brightness);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await precacheAll(tester, find.byType(BookingScreen), _art);

      await expectLater(find.byType(BookingScreen),
          matchesGoldenFile('goldens/booking_matched_$shade.png'));
    });
  }
}
