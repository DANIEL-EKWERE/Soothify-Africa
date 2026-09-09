import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/routes/app_pages.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/widgets/skeleton.dart';

import 'helpers.dart';

/// Motion the app relies on, and the two ways it has already gone wrong.
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  group('route transitions', () {
    test('every route either inherits the default or names its own', () {
      // The app sets one default; a route only overrides it to say something
      // different — a sheet rising, a celebration fading.
      final overridden = {
        for (final p in AppPages.pages)
          if (p.transition != null) p.name: p.transition,
      };
      expect(overridden[AppRoutes.aiHub], Transition.downToUp);
      expect(overridden[AppRoutes.filterDuration], Transition.downToUp);
      expect(overridden[AppRoutes.filterMore], Transition.downToUp);
      expect(overridden[AppRoutes.filterStyle], Transition.downToUp);
      expect(overridden[AppRoutes.moodRecord], Transition.fadeIn);
      // Everything else takes the app-wide one.
      expect(overridden, hasLength(5));
    });
  });

  group('ContentReveal', () {
    testWidgets('is a no-op under reduce motion', (tester) async {
      useDesignFrame(tester);
      disableMotion(tester);

      // No MaterialApp: its own route machinery brings FadeTransitions of
      // its own, which would mask whether ContentReveal added one.
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: ContentReveal(
            delay: Duration(seconds: 5),
            child: SizedBox(key: Key('body')),
          ),
        ),
      );
      // No pending timer, no transition wrappers — just the child.
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('body')), findsOneWidget);
      expect(find.byType(FadeTransition), findsNothing);
      expect(find.byType(SlideTransition), findsNothing);
    });

    testWidgets('survives being disposed before its delay elapses',
        (tester) async {
      useDesignFrame(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: ContentReveal(
            delay: const Duration(seconds: 5),
            child: Container(key: const Key('body')),
          ),
        ),
      );
      await tester.pump();

      // Tearing the row out mid-wait used to leave a timer that woke up and
      // started an animation on a dead element.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump(const Duration(seconds: 6));

      expect(tester.takeException(), isNull);
    });

    testWidgets('builds its controller eagerly, so dispose is safe under '
        'reduce motion', (tester) async {
      useDesignFrame(tester);
      disableMotion(tester);

      await tester.pumpWidget(
        const MaterialApp(home: SkeletonShimmer(child: Text('x'))),
      );
      await tester.pumpAndSettle();
      // A lazily-created controller would be constructed here for the first
      // time, during unmount, and throw looking up its ticker.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('SkeletonShimmer', () {
    testWidgets('stops sweeping under reduce motion', (tester) async {
      useDesignFrame(tester);
      disableMotion(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: SkeletonShimmer(child: Skeleton(width: 100, height: 20)),
        ),
      );
      // Settles: a shimmer left running would never give pumpAndSettle a
      // still frame, which is what would hang every golden.
      await tester.pumpAndSettle();
      expect(find.byType(Skeleton), findsOneWidget);
    });
  });
}
