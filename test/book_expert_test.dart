import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/expert_session_type.dart';
import 'package:soothifyafrica/app/data/models/wellness_kyc.dart';
import 'package:soothifyafrica/app/modules/user/book_expert/book_expert_screen.dart';
import 'package:soothifyafrica/app/modules/user/book_expert/controller/book_expert_controller.dart';
import 'package:soothifyafrica/app/widgets/custom_elevated_button.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/book_expert_test.dart
const _art = [
  'assets/images/explore/book_expert.png',
  'assets/images/explore/stretch_restore.png',
  'assets/images/explore/pilates_core.png',
];

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<BookExpertController> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(BookExpertController());
    await pumpScreen(tester, const BookExpertScreen(), brightness: brightness);
    return c;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('book expert, $name', (tester) async {
      await mount(tester, brightness: brightness);
      await precacheAll(tester, find.byType(BookExpertScreen), _art);

      // The frame is 1330 tall against an 844 viewport, so the golden holds
      // the first two cards and the top of the third.
      await expectLater(find.byType(BookExpertScreen),
          matchesGoldenFile('goldens/book_expert_$name.png'));
    });
  }

  testWidgets('the three disciplines are the frame’s, in its order',
      (tester) async {
    await mount(tester);
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Schedule live sessions\nwith experts'), findsOneWidget);

    // Therapy, yoga, Pilates — note this is NOT the section set (therapy,
    // Pilates & Core, Stretch & Restore); yoga appears only here.
    expect(ExpertSessionType.values.map((o) => o.title), [
      '1-on-1 virtual therapy session',
      '1-on-1 virtual yoga session',
      '1-on-1 virtual Pilates session',
    ]);
    expect(find.text('1-on-1 virtual therapy session'), findsOneWidget);
    expect(find.text('1-on-1 virtual yoga session'), findsOneWidget);
  });

  testWidgets('every card offers the same blurb and action', (tester) async {
    await mount(tester);
    await tester.scrollUntilVisible(
      find.text('1-on-1 virtual Pilates session'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('One on one session with a\nprofessional'),
        findsNWidgets(3));
    expect(find.text('Book session'), findsNWidgets(3));
  });

  testWidgets('the card action is the frame’s 48, not the app’s 52',
      (tester) async {
    await mount(tester);
    final button =
        tester.widget<CustomElevatedButton>(find.byType(CustomElevatedButton).first);
    expect(button.height, 48);
  });

  testWidgets('each card opens its own questionnaire', (tester) async {
    final c = await mount(tester);

    // The yoga card shares Stretch & Restore's: `Scheduling Kyc/Yoga`
    // (259:38802) plus the `Yoga Kyc` row is that section's questionnaire,
    // and yoga is what it asks about. The Pilates card shares Pilates &
    // Core's for the same reason.
    expect(c.trackFor(ExpertSessionType.therapy), WellnessTrack.therapy);
    expect(c.trackFor(ExpertSessionType.yoga), WellnessTrack.balance);
    expect(c.trackFor(ExpertSessionType.pilates), WellnessTrack.meditation);

    // Three cards, three destinations — none of them shared.
    final tracks =
        ExpertSessionType.values.map(c.trackFor).toSet();
    expect(tracks, hasLength(3));
  });

  test('the photographs are stand-ins until the fills are exported', () {
    // Three distinct image fills in the frame, none of them fetched. If these
    // ever point at real exports this expectation is what says so.
    expect(
      ExpertSessionType.values.map((o) => o.assetPath).toSet(),
      hasLength(3),
      reason: 'one photograph per card, as the frame draws it',
    );
  });
}
