import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';
import 'package:soothifyafrica/app/widgets/ai_assist_overlay.dart';
import 'package:soothifyafrica/app/widgets/ai_assist_button.dart';

import 'helpers.dart';

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    // A static observable, so Get.reset does not clear it between tests.
    AiAssistOverlay.route.value = null;
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
    // The spring overshoots before it settles, so give it longer than a
    // fixed tween would need.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final after = positionOf(tester);

    // A short drag from the right-hand rest position stays nearer the right,
    // so it settles back against that edge — moved vertically, not adrift.
    expect(after.dx, closeTo(390 - 70, 1));
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

  testWidgets('dropped mid-screen it snaps to the nearer edge', (tester) async {
    useDesignFrame(tester);
    await mount(tester);

    // Drag it towards the middle and let go.
    await tester.drag(find.byType(AiAssistButton), const Offset(-160, -300));
    await tester.pump();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final at = positionOf(tester);
    final maxX = 390 - 70;
    // Against one edge or the other, never left floating between them.
    expect(
      at.dx < 1 || (at.dx - maxX).abs() < 1,
      isTrue,
      reason: 'left at dx=${at.dx}, which is neither edge',
    );
  });

  /// The overlay is what makes the button app-wide. Mounted inside the Home
  /// tab it disappeared the moment anything else opened, and came back at its
  /// default corner — which is what "not persistent across the app" meant.
  group('the app-wide overlay', () {
    Future<void> mountApp(WidgetTester tester, {String? at}) async {
      AiAssistOverlay.route.value = at;
      await tester.pumpWidget(
        Sizer(
          builder: (_, _, _) => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            routingCallback: AiAssistOverlay.onRouting,
            builder: (context, child) => AiAssistOverlay(child: child!),
            getPages: [
              GetPage(
                name: AppRoutes.shell,
                page: () => const Scaffold(body: Text('shell')),
              ),
              GetPage(
                name: AppRoutes.settings,
                page: () => const Scaffold(body: Text('settings')),
              ),
              GetPage(
                name: AppRoutes.signin,
                page: () => const Scaffold(body: Text('signin')),
              ),
              GetPage(
                name: AppRoutes.aiHub,
                page: () => const Scaffold(body: Text('ai hub')),
              ),
            ],
            initialRoute: at ?? AppRoutes.shell,
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('it stays out of onboarding and auth', (tester) async {
      useDesignFrame(tester);
      await mountApp(tester, at: AppRoutes.signin);

      expect(find.byType(AiAssistButton), findsNothing);
    });

    testWidgets('it is there on an in-app screen', (tester) async {
      useDesignFrame(tester);
      await mountApp(tester, at: AppRoutes.shell);

      expect(find.byType(AiAssistButton), findsOneWidget);
    });

    testWidgets('a push does not move it or remount it', (tester) async {
      useDesignFrame(tester);
      await mountApp(tester, at: AppRoutes.shell);

      // Park it against the left edge, away from where it starts.
      await tester.drag(find.byType(AiAssistButton), const Offset(-300, -200));
      await tester.pump();
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final parked = tester.getTopLeft(find.byType(AiAssistButton));
      expect(parked.dx, closeTo(0, 1), reason: 'should have gone left');

      Get.toNamed(AppRoutes.settings);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('settings'), findsOneWidget);
      expect(
        find.byType(AiAssistButton),
        findsOneWidget,
        reason: 'the button must survive the push',
      );
      // Same x: a remount would have snapped it back to the right edge.
      expect(
        tester.getTopLeft(find.byType(AiAssistButton)).dx,
        closeTo(parked.dx, 1),
      );
    });

    testWidgets('tapping it opens the AI Hub, and it steps aside there',
        (tester) async {
      useDesignFrame(tester);
      await mountApp(tester, at: AppRoutes.shell);

      await tester.tap(find.byType(AiAssistButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('ai hub'), findsOneWidget);
      // The hub is the button's own destination, so it must not float over it.
      expect(find.byType(AiAssistButton), findsNothing);
    });

  });
}
