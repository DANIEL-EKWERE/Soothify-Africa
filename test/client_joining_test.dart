import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/modules/user/session/client_joining_screen.dart';
import 'package:soothifyafrica/app/modules/user/session/controller/client_joining_controller.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/client_joining_test.dart
const _art = ['assets/images/coach/photo.png'];

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<ClientJoiningController> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(ClientJoiningController());
    await pumpScreen(tester, const ClientJoiningScreen(),
        brightness: brightness);
    return c;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('client joining, $name', (tester) async {
      await mount(tester, brightness: brightness);
      await precacheAll(tester, find.byType(ClientJoiningScreen), _art);

      await expectLater(find.byType(ClientJoiningScreen),
          matchesGoldenFile('goldens/client_joining_$name.png'));
    });
  }

  testWidgets('the frame’s two typos are not shipped', (tester) async {
    await mount(tester);
    // The frame reads "Session in Progess" and "Seesion Time".
    expect(find.text('Session in Progress'), findsOneWidget);
    expect(find.text('Session in Progess'), findsNothing);
    expect(find.text('Session Time'), findsOneWidget);
    expect(find.text('Seesion Time'), findsNothing);
  });

  testWidgets('the Care Guarantee is stated where the frame states it',
      (tester) async {
    await mount(tester);
    // Twice, as `280:26643` draws it: bare under "Joining Call", where it
    // reads as a promise made on arrival, and again inside the titled panel.
    // It was shipping once; the designer's screenshot of 2026-10-05 settles
    // that both are meant.
    expect(find.textContaining('protected under our Care Guarantee'),
        findsNWidgets(2));
    expect(find.text('Your Safe Space is Protected'), findsOneWidget);
  });

  testWidgets('it shows the expert, not the client', (tester) async {
    final c = await mount(tester);
    expect(find.text('Expert'), findsOneWidget);
    expect(find.text(c.expertName), findsOneWidget);
    expect(find.text(c.service), findsOneWidget);
    expect(find.text(c.time), findsOneWidget);
  });

  testWidgets('the mic and camera start on and toggle their labels',
      (tester) async {
    final c = await mount(tester);
    expect(c.micOn.value, isTrue);
    expect(c.cameraOn.value, isTrue);
    expect(find.text('Mute Mic'), findsOneWidget);
    expect(find.text('Turn Off Camera'), findsOneWidget);

    c.toggleMic();
    c.toggleCamera();
    await tester.pumpAndSettle();
    expect(find.text('Unmute Mic'), findsOneWidget);
    expect(find.text('Turn On Camera'), findsOneWidget);
  });

  testWidgets('Cancel is the only action', (tester) async {
    await mount(tester);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
