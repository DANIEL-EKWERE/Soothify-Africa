import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/wellness_space.dart';
import 'package:soothifyafrica/app/modules/user/spaces/controller/spaces_controller.dart';
import 'package:soothifyafrica/app/modules/user/spaces/spaces_screen.dart';
import 'package:soothifyafrica/app/modules/user/spaces/studio_profile_screen.dart';
import 'package:soothifyafrica/app/modules/user/spaces/widgets/passport_sheet.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/spaces_test.dart
const _art = [
  'assets/images/spaces/studio.png',
  'assets/images/spaces/map.png',
];

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<SpacesController> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(SpacesController());
    await pumpScreen(tester, const SpacesScreen(), brightness: brightness);
    return c;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('spaces list, $name', (tester) async {
      await mount(tester, brightness: brightness);
      await precacheAll(tester, find.byType(SpacesScreen), _art);

      await expectLater(find.byType(SpacesScreen),
          matchesGoldenFile('goldens/spaces_list_$name.png'));
    });

    testWidgets('spaces map, $name', (tester) async {
      final c = await mount(tester, brightness: brightness);
      c.showMap();
      await tester.pumpAndSettle();
      await precacheAll(tester, find.byType(SpacesScreen), _art);

      await expectLater(find.byType(SpacesScreen),
          matchesGoldenFile('goldens/spaces_map_$name.png'));
    });
  }

  testWidgets('spaces map with a pin open', (tester) async {
    final c = await mount(tester);
    c.showMap();
    c.selectPin(WellnessSpace.sample.first);
    await tester.pumpAndSettle();
    await precacheAll(tester, find.byType(SpacesScreen), _art);

    await expectLater(find.byType(SpacesScreen),
        matchesGoldenFile('goldens/spaces_map_pin.png'));
  });

  testWidgets('studio profile', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(SpacesController());
    await pumpScreen(tester, const StudioProfileScreen());
    await precacheAll(tester, find.byType(StudioProfileScreen), _art);

    await expectLater(find.byType(StudioProfileScreen),
        matchesGoldenFile('goldens/studio_profile.png'));
  });

  testWidgets('the list carries the frame’s chrome', (tester) async {
    await mount(tester);
    expect(find.text('Spaces Around Me'), findsOneWidget);
    expect(find.text('Find a quiet space near you...'), findsOneWidget);
    for (final c in SpaceCategory.values) {
      expect(find.text(c.label), findsOneWidget);
    }
    expect(find.text('List'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
  });

  testWidgets('the filter chips narrow the list', (tester) async {
    final c = await mount(tester);
    expect(c.spaces, hasLength(WellnessSpace.sample.length));

    c.choose(SpaceCategory.pilates);
    await tester.pumpAndSettle();
    expect(c.spaces.every((s) => s.category == SpaceCategory.pilates), isTrue);
    expect(c.spaces, isNotEmpty);

    c.choose(SpaceCategory.all);
    await tester.pumpAndSettle();
    expect(c.spaces, hasLength(WellnessSpace.sample.length));
  });

  testWidgets('search matches a name, an area or a tag', (tester) async {
    final c = await mount(tester);
    c.search.text = 'lekki';
    await tester.pumpAndSettle();
    expect(c.spaces.single.area, 'Lekki Phase 1');

    c.search.text = 'reformer';
    await tester.pumpAndSettle();
    expect(c.spaces.single.name, 'Sage & She');

    c.search.text = 'nowhere at all';
    await tester.pumpAndSettle();
    expect(c.spaces, isEmpty);
    // An empty list says so rather than showing a blank screen.
    expect(find.textContaining('No spaces match'), findsOneWidget);
  });

  testWidgets('a pin opens a card, and leaving the map closes it',
      (tester) async {
    final c = await mount(tester);
    c.showMap();
    await tester.pumpAndSettle();
    expect(find.text('Tap a pin to preview a space'), findsOneWidget);

    c.selectPin(WellnessSpace.sample.first);
    await tester.pumpAndSettle();
    expect(find.text('Tap a pin to preview a space'), findsNothing);
    expect(find.text('Get Directions'), findsOneWidget);

    c.showList();
    await tester.pumpAndSettle();
    expect(c.selected.value, isNull,
        reason: 'a card left open would spring back on the next map view');
  });

  testWidgets('a filter that excludes the open pin closes it', (tester) async {
    final c = await mount(tester);
    c.showMap();
    c.selectPin(WellnessSpace.sample.first); // a Pilates studio
    await tester.pumpAndSettle();

    c.choose(SpaceCategory.spa);
    await tester.pumpAndSettle();
    expect(c.selected.value, isNull);
  });

  testWidgets('the Passport teaser is a link, and says it is not open yet',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(SpacesController());
    Get.testMode = true;
    await pumpScreen(tester, const StudioProfileScreen());

    // It is the last thing in the sheet, so it starts below the fold.
    final teaser = find.textContaining('Love this studio?');
    await tester.scrollUntilVisible(
      teaser,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // `282:25364` is one text node in two runs — the question in body ink and
    // everything from "Get" in #2F6FED. Rendering it flat loses the only
    // thing that says it can be tapped.
    final span = tester.widget<Text>(teaser).textSpan! as TextSpan;
    final parts = span.children!.cast<TextSpan>();
    expect(parts, hasLength(2));
    expect(parts.first.text, 'Love this studio? ');
    expect(parts.last.text, 'Get early access to Passport passes');
    expect(parts.last.style!.color, isNot(parts.first.style!.color),
        reason: 'the link half is the only part the frame colours blue');

    // It opens the waitlist sheet.
    await tester.tap(teaser);
    await tester.pumpAndSettle();
    expect(find.byType(PassportSheet), findsOneWidget);
    expect(find.text(PassportSheet.heading), findsOneWidget);
    for (final paragraph in PassportSheet.body) {
      expect(find.text(paragraph), findsOneWidget);
    }
  });

  testWidgets('the sheet carries the designer’s words unchanged',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await pumpScreen(tester, const PassportSheet());

    // Supplied by the designer rather than read from the file — the sheet is
    // not a frame on page 124:2. If it ever is, these are what to check the
    // frame against.
    expect(PassportSheet.heading, 'Step into the broader sanctuary');
    expect(PassportSheet.body.first, startsWith('We are putting together'));
    expect(PassportSheet.body.first, contains('Abuja and Lagos'));
    expect(PassportSheet.body.last, contains('the moment our doors open'));
    expect(find.text('Notify me'), findsOneWidget);
  });

  test('every sample space is reachable through some chip', () {
    for (final space in WellnessSpace.sample) {
      expect(SpaceCategory.values, contains(space.category));
    }
    // And the pins sit inside the map, not off its edge.
    for (final space in WellnessSpace.sample) {
      expect(space.pin.x, inInclusiveRange(0, 1));
      expect(space.pin.y, inInclusiveRange(0, 1));
    }
  });
}
