import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';
import 'package:soothifyafrica/app/modules/user/shell/tabs/widgets/ai_assist_button.dart';

import 'helpers.dart';

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  /// Mounted without pumpAndSettle anywhere: the button drifts forever, so
  /// there is never a frame-free moment to settle on and every settle would
  /// time out.
  Future<void> mount(WidgetTester tester, {VoidCallback? onTap}) async {
    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: Scaffold(
            body: Stack(
              children: [
                AiAssistButton(
                  onTap: onTap ?? () {},
                  bounds: const Size(390, 844),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Offset positionOf(WidgetTester tester) =>
      tester.getTopLeft(find.byType(AiAssistButton));

  testWidgets('it drifts while idle', (tester) async {
    useDesignFrame(tester);
    await mount(tester);

    final first = positionOf(tester).dy;
    await tester.pump(AiAssistButton.driftPeriod);
    final later = positionOf(tester).dy;

    // A full period apart it sits at the opposite end of its travel, so the
    // gap is the whole span rather than half of it.
    expect((later - first).abs(), closeTo(AiAssistButton.drift * 2, 0.5));
  });

  testWidgets('it can be dragged elsewhere and stays put', (tester) async {
    useDesignFrame(tester);
    await mount(tester);

    final before = positionOf(tester);
    await tester.drag(find.byType(AiAssistButton), const Offset(-120, -200));
    await tester.pump();
    final after = positionOf(tester);

    expect(after.dx, lessThan(before.dx));
    expect(after.dy, lessThan(before.dy));

    // And it does not drift back: a dragged position is where the user put it.
    await tester.pump(AiAssistButton.driftPeriod);
    expect(positionOf(tester).dx, after.dx);
  });

  testWidgets('it cannot be dragged off screen', (tester) async {
    useDesignFrame(tester);
    await mount(tester);

    // Well past the top-left corner.
    await tester.drag(find.byType(AiAssistButton), const Offset(-900, -1400));
    await tester.pump();

    final at = positionOf(tester);
    expect(at.dx, greaterThanOrEqualTo(0));
    expect(at.dy, greaterThanOrEqualTo(0));
  });

  testWidgets('tapping it still works after a drag', (tester) async {
    useDesignFrame(tester);
    var taps = 0;
    await mount(tester, onTap: () => taps++);

    await tester.drag(find.byType(AiAssistButton), const Offset(-60, -60));
    await tester.pump();
    await tester.tap(find.byType(AiAssistButton));
    await tester.pump();

    expect(taps, 1);
  });
}
