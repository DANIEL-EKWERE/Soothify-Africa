import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';

import 'package:soothifyafrica/app/core/errors/app_exception.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/data/models/mood.dart';
import 'package:soothifyafrica/app/routes/app_pages.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/kyc_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_kyc_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_mood_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mood_repository.dart';
import 'package:soothifyafrica/app/modules/user/mood_checker/controller/mood_checker_controller.dart';
import 'package:soothifyafrica/app/modules/user/mood_checker/mood_checker_screen.dart';

/// Repository whose writes always fail, to exercise the failure path.
class _FailingMoodRepository implements MoodRepository {
  @override
  Future<List<MoodEntry>> history({int limit = 50}) async => const [];
  @override
  Future<MoodEntry> record(double score, {String note = ''}) async =>
      throw const ServerException();
  @override
  Future<List<MoodEntry>> between(DateTime from, DateTime to) async => const [];
  @override
  Future<MoodEntry?> todaysEntry() async => null;
}

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    // The default 800x600 test surface distorts responsive sizing. Pin it to
    // the design frame so .h and .v resolve 1:1, as on a reference device.
    final view = TestWidgetsFlutterBinding
        .ensureInitialized().platformDispatcher.implicitView!;
    view.physicalSize = const Size(figmaDesignWidth * 3, figmaDesignHeight * 3);
    view.devicePixelRatio = 3.0;
  });

  tearDown(() {
    Get.reset();
    TestWidgetsFlutterBinding
        .ensureInitialized().platformDispatcher.implicitView!
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });

  // Routes are registered because committing a mood navigates on to the
  // records screen, as the designed flow does.
  Widget wrap(Widget child) => Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          getPages: AppPages.pages,
          home: child,
        ),
      );

  MoodCheckerController putController(MoodRepository repo) {
    Get.put<MoodRepository>(repo);
    Get.put<KycRepository>(LocalKycRepository());
    // Committing a mood now opens the recommendation, whose binding resolves
    // content — so the flow needs a repository even from the checker's tests.
    Get.put<ContentRepository>(MockContentRepository());
    return Get.put(MoodCheckerController(repo, Get.find<KycRepository>()));
  }

  group('MoodLevel', () {
    test('ten even bands across the track', () {
      expect(MoodLevel.values, hasLength(10));
      expect(MoodLevel.forScore(0.0), MoodLevel.awful);
      expect(MoodLevel.forScore(0.09), MoodLevel.awful);
      expect(MoodLevel.forScore(0.10), MoodLevel.drained);
      expect(MoodLevel.forScore(0.45), MoodLevel.neutral);
      expect(MoodLevel.forScore(0.55), MoodLevel.reflective);
      expect(MoodLevel.forScore(1.0), MoodLevel.awesome);
    });

    test('out-of-range scores clamp rather than throw', () {
      expect(MoodLevel.forScore(-5), MoodLevel.awful);
      expect(MoodLevel.forScore(42), MoodLevel.awesome);
    });

    test('a level round-trips through its own representative score', () {
      for (final l in MoodLevel.values) {
        expect(MoodLevel.forScore(l.representativeScore), l,
            reason: '${l.label} does not land back on itself');
      }
    });

    test('every mood carries the copy its own frame prints', () {
      for (final l in MoodLevel.values) {
        expect(l.recommendationIntro, isNotEmpty, reason: l.label);
      }
      // Each is written for that mood; none is a shared fallback.
      expect(
        MoodLevel.values.map((l) => l.recommendationIntro).toSet(),
        hasLength(MoodLevel.values.length),
      );
      expect(MoodLevel.awful.recommendationIntro,
          startsWith('Ah, today feels heavy.'));
      expect(MoodLevel.awesome.recommendationIntro,
          startsWith('Absolute top form today!'));
    });

    test('the keys are stable identifiers, not labels', () {
      expect(MoodLevel.neutral.key, 'neutral');
      // The frame's tab says "Neutra"; the word is Neutral.
      expect(MoodLevel.neutral.label, 'Neutral');
    });
  });

  group('MoodFigure', () {
    test('only an explicit "male" answer gets the male set', () {
      expect(MoodFigure.fromKycAnswer('male'), MoodFigure.male);
      expect(MoodFigure.fromKycAnswer('female'), MoodFigure.female);
      expect(MoodFigure.fromKycAnswer('non_binary'), MoodFigure.female);
      expect(MoodFigure.fromKycAnswer(null), MoodFigure.female);
    });

    test('every mood has its own drawing, for both figures', () {
      // Was four female and three male, with the other thirteen borrowing a
      // neighbour. All twenty are drawn now, so nothing repeats.
      for (final f in MoodFigure.values) {
        for (final l in MoodLevel.values) {
          expect(f.artFor(l), 'assets/images/mood/${f.key}_${l.key}.png');
        }
        expect(f.allArt, hasLength(MoodLevel.values.length));
      }
    });

    test('the twenty files the model names are all on disk', () {
      for (final f in MoodFigure.values) {
        for (final path in f.allArt) {
          expect(File(path).existsSync(), isTrue, reason: '$path is missing');
        }
      }
    });
  });

  group('LocalMoodRepository', () {
    test('records an entry and reads it back as today\'s', () async {
      final repo = LocalMoodRepository();
      expect(await repo.todaysEntry(), isNull);

      await repo.record(0.8);
      final today = await repo.todaysEntry();

      expect(today, isNotNull);
      expect(today!.score, closeTo(0.8, 1e-9));
      // Asserted by position on the scale, not by name: the band a score
      // lands in moved once already, when four levels became ten.
      expect(today.level.index, greaterThan(MoodLevel.neutral.index));
    });

    test('re-checking replaces today\'s entry rather than stacking', () async {
      final repo = LocalMoodRepository();
      await repo.record(0.1);
      await repo.record(0.9);

      final all = await repo.history();
      expect(all, hasLength(1));
      expect(all.single.score, closeTo(0.9, 1e-9));
    });
  });

  group('MoodEntry', () {
    test('an entry saved before the slider still reads back', () {
      // Nine named moods used to be persisted under a "mood" key. Dropping
      // those would wipe a user's calendar and streak on upgrade.
      final legacy = MoodEntry.fromJson({
        'id': '1',
        'mood': 'happy',
        'recorded_at': '2026-01-02T10:00:00Z',
      });
      expect(legacy.level.index, greaterThan(MoodLevel.neutral.index));

      final sad = MoodEntry.fromJson({
        'id': '2',
        'mood': 'sad',
        'recorded_at': '2026-01-02T10:00:00Z',
      });
      expect(sad.level.index, lessThan(MoodLevel.neutral.index));
    });

    test('a score wins over a legacy mood key when both are present', () {
      final e = MoodEntry.fromJson({
        'id': '3',
        'mood': 'sad',
        'score': 0.9,
        'recorded_at': '2026-01-02T10:00:00Z',
      });
      expect(e.level.index, greaterThan(MoodLevel.neutral.index));
    });
  });

  group('MoodCheckerScreen', () {
    testWidgets('shows the question, the slider and both end labels',
        (tester) async {
      putController(LocalMoodRepository());

      await tester.pumpWidget(wrap(const MoodCheckerScreen()));
      await tester.pumpAndSettle();

      expect(find.text('How do you feel today?'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Awful'), findsOneWidget);
      expect(find.text('Awesome'), findsOneWidget);
      expect(find.text('Add Detail'), findsOneWidget);
    });

    testWidgets('dragging the slider swaps the illustration', (tester) async {
      final controller = putController(LocalMoodRepository());

      await tester.pumpWidget(wrap(const MoodCheckerScreen()));
      await tester.pumpAndSettle();

      controller.setScore(0.0);
      await tester.pumpAndSettle();
      final worst = controller.artPath;

      controller.setScore(1.0);
      await tester.pumpAndSettle();

      expect(controller.artPath, isNot(worst));
      expect(controller.level, MoodLevel.values.last);
    });

    testWidgets('nothing is written until the button is pressed',
        (tester) async {
      final repo = LocalMoodRepository();
      final controller = putController(repo);

      await tester.pumpWidget(wrap(const MoodCheckerScreen()));
      await tester.pumpAndSettle();

      // Dragging around to look at the faces must not keep rewriting today.
      controller.setScore(0.1);
      controller.setScore(0.9);
      await tester.pumpAndSettle();
      expect(await repo.todaysEntry(), isNull);

      await tester.tap(find.text('Add Detail'));
      await tester.pumpAndSettle();

      expect((await repo.todaysEntry())!.score, closeTo(0.9, 1e-9));
      // A completed check-in opens what the app offers back for that mood;
      // the day's record follows from there.
      expect(Get.currentRoute, AppRoutes.moodRecommendation);
    });

    testWidgets('a failed write does not navigate on', (tester) async {
      putController(_FailingMoodRepository());

      await tester.pumpWidget(wrap(const MoodCheckerScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Detail'));
      await tester.pumpAndSettle();

      expect(Get.currentRoute, isNot(AppRoutes.moodRecommendation));

      // Let the failure snackbar run its 3s dismiss timer out, otherwise the
      // binding reports a pending timer when the test ends.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('reopening puts the handle back where it was left',
        (tester) async {
      final repo = LocalMoodRepository();
      await repo.record(0.15);
      final controller = putController(repo);

      await tester.pumpWidget(wrap(const MoodCheckerScreen()));
      await tester.pumpAndSettle();

      expect(controller.score.value, closeTo(0.15, 1e-9));
      // Position on the scale, not a name: the bands moved when four levels
      // became ten and will move again if more are added.
      expect(controller.level.index, lessThan(MoodLevel.neutral.index));
    });
  });

  testWidgets('every mood illustration fills its canvas', (tester) async {
    // The figures are drawn edge to edge. female_drained arrived with 70 of
    // transparent margin baked into it, so at the same box it rendered
    // noticeably smaller than the nine beside it.
    await tester.runAsync(() async {
      for (final figure in MoodFigure.values) {
        for (final level in MoodLevel.values) {
          final path = 'assets/images/mood/${figure.key}_${level.key}.png';
          final codec = await ui.instantiateImageCodec(
            await File(path).readAsBytes(),
          );
          final image = (await codec.getNextFrame()).image;
          final pixels = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;

          var left = image.width, right = -1, top = image.height, bottom = -1;
          for (var y = 0; y < image.height; y++) {
            for (var x = 0; x < image.width; x++) {
              if (pixels.getUint8((y * image.width + x) * 4 + 3) <= 24) {
                continue;
              }
              if (x < left) left = x;
              if (x > right) right = x;
              if (y < top) top = y;
              if (y > bottom) bottom = y;
            }
          }

          expect((right - left + 1) / image.width, greaterThan(0.97),
              reason: '$path does not fill its canvas across');
          expect((bottom - top + 1) / image.height, greaterThan(0.97),
              reason: '$path does not fill its canvas down');
          image.dispose();
        }
      }
    });
  });
}
