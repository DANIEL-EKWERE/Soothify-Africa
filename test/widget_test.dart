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
import 'package:soothifyafrica/app/data/repositories/local_mood_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mood_repository.dart';
import 'package:soothifyafrica/app/modules/user/mood_checker/controller/mood_checker_controller.dart';
import 'package:soothifyafrica/app/modules/user/mood_checker/mood_checker_screen.dart';
import 'package:soothifyafrica/app/modules/user/mood_checker/widgets/mood_tile.dart';

/// Repository whose writes always fail, to exercise the rollback path.
class _FailingMoodRepository implements MoodRepository {
  @override
  Future<List<MoodEntry>> history({int limit = 50}) async => const [];
  @override
  Future<MoodEntry> record(Mood mood, {String note = ''}) async =>
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

  // Routes are registered because recording a mood navigates on to the
  // records screen, as the designed flow does.
  Widget wrap(Widget child) => Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          getPages: AppPages.pages,
          home: child,
        ),
      );

  group('LocalMoodRepository', () {
    test('records an entry and reads it back as today\'s', () async {
      final repo = LocalMoodRepository();
      expect(await repo.todaysEntry(), isNull);

      await repo.record(Mood.calm);
      final today = await repo.todaysEntry();

      expect(today, isNotNull);
      expect(today!.mood, Mood.calm);
    });

    test('re-checking replaces today\'s entry rather than stacking', () async {
      final repo = LocalMoodRepository();
      await repo.record(Mood.sad);
      await repo.record(Mood.happy);

      final all = await repo.history();
      expect(all, hasLength(1));
      expect(all.single.mood, Mood.happy);
    });
  });

  group('MoodCheckerScreen', () {
    testWidgets('renders all nine moods from the design', (tester) async {
      Get.put<MoodRepository>(LocalMoodRepository());
      Get.put(MoodCheckerController(Get.find<MoodRepository>()));

      await tester.pumpWidget(wrap(const MoodCheckerScreen()));
      await tester.pumpAndSettle();

      expect(find.text('How do you feel today?'), findsOneWidget);
      expect(find.byType(MoodTile), findsNWidgets(9));
      for (final mood in Mood.values) {
        expect(find.text(mood.label), findsOneWidget);
      }
    });

    testWidgets('tapping a mood persists it', (tester) async {
      final repo = LocalMoodRepository();
      Get.put<MoodRepository>(repo);
      final controller = Get.put(MoodCheckerController(repo));

      await tester.pumpWidget(wrap(const MoodCheckerScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Happy'));
      await tester.pumpAndSettle();

      expect(controller.selected.value, Mood.happy);
      expect((await repo.todaysEntry())!.mood, Mood.happy);
      // A completed check-in leads straight to the records screen.
      expect(Get.currentRoute, AppRoutes.moodRecord);
    });

    testWidgets('selection rolls back when the write fails', (tester) async {
      Get.put<MoodRepository>(_FailingMoodRepository());
      final controller =
          Get.put(MoodCheckerController(Get.find<MoodRepository>()));

      await tester.pumpWidget(wrap(const MoodCheckerScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sad'));
      await tester.pumpAndSettle();

      // The UI must not show a choice that was never saved.
      expect(controller.selected.value, isNull);

      // Let the failure snackbar run its 3s dismiss timer out, otherwise the
      // binding reports a pending timer when the test ends.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });
  });
}
