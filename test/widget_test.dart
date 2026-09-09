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
import 'package:soothifyafrica/app/data/repositories/kyc_repository.dart';
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
    return Get.put(MoodCheckerController(repo, Get.find<KycRepository>()));
  }

  group('MoodLevel', () {
    test('the slider crosses into a new face at the design thresholds', () {
      expect(MoodLevel.forScore(0.0), MoodLevel.awful);
      expect(MoodLevel.forScore(0.19), MoodLevel.awful);
      expect(MoodLevel.forScore(0.20), MoodLevel.low);
      expect(MoodLevel.forScore(0.44), MoodLevel.low);
      expect(MoodLevel.forScore(0.45), MoodLevel.good);
      expect(MoodLevel.forScore(0.69), MoodLevel.good);
      expect(MoodLevel.forScore(0.70), MoodLevel.awesome);
      expect(MoodLevel.forScore(1.0), MoodLevel.awesome);
    });

    test('out-of-range scores clamp rather than throw', () {
      expect(MoodLevel.forScore(-5), MoodLevel.awful);
      expect(MoodLevel.forScore(42), MoodLevel.awesome);
    });
  });

  group('MoodFigure', () {
    test('only an explicit "male" answer gets the male set', () {
      expect(MoodFigure.fromKycAnswer('male'), MoodFigure.male);
      expect(MoodFigure.fromKycAnswer('female'), MoodFigure.female);
      expect(MoodFigure.fromKycAnswer('non_binary'), MoodFigure.female);
      expect(MoodFigure.fromKycAnswer(null), MoodFigure.female);
    });

    test('the male set reuses one illustration for its top two steps', () {
      // The design draws only three male faces across four handle positions.
      expect(
        MoodFigure.male.artFor(MoodLevel.awesome),
        MoodFigure.male.artFor(MoodLevel.good),
      );
      expect(MoodFigure.male.allArt, hasLength(3));
      expect(MoodFigure.female.allArt, hasLength(4));
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
      expect(today.level, MoodLevel.awesome);
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
      expect(legacy.level, MoodLevel.awesome);

      final sad = MoodEntry.fromJson({
        'id': '2',
        'mood': 'sad',
        'recorded_at': '2026-01-02T10:00:00Z',
      });
      expect(sad.level, MoodLevel.awful);
    });

    test('a score wins over a legacy mood key when both are present', () {
      final e = MoodEntry.fromJson({
        'id': '3',
        'mood': 'sad',
        'score': 0.9,
        'recorded_at': '2026-01-02T10:00:00Z',
      });
      expect(e.level, MoodLevel.awesome);
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
      expect(controller.level, MoodLevel.awesome);
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
      // A completed check-in leads straight to the records screen.
      expect(Get.currentRoute, AppRoutes.moodRecord);
    });

    testWidgets('a failed write does not navigate on', (tester) async {
      putController(_FailingMoodRepository());

      await tester.pumpWidget(wrap(const MoodCheckerScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Detail'));
      await tester.pumpAndSettle();

      expect(Get.currentRoute, isNot(AppRoutes.moodRecord));

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
      expect(controller.level, MoodLevel.awful);
    });
  });
}
