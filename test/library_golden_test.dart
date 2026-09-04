import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/library_section.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/modules/user/library/controller/library_controller.dart';
import 'package:soothifyafrica/app/modules/user/library/library_screen.dart';
import 'package:soothifyafrica/app/modules/user/schedule/controller/schedule_controller.dart';
import 'package:soothifyafrica/app/modules/user/schedule/schedule_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/library_golden_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  for (final section in LibrarySection.values) {
    for (final (name, brightness) in [
      ('light', Brightness.light),
      ('dark', Brightness.dark),
    ]) {
      testWidgets('${section.id}, $name', (tester) async {
        useDesignFrame(tester);
        await loadAppFonts();
        Get.put<ContentRepository>(MockContentRepository());
        Get.lazyPut(
          () => LibraryController(Get.find<ContentRepository>(), section),
        );

        await pumpScreen(tester, const LibraryScreen(),
            brightness: brightness);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        await expectLater(find.byType(LibraryScreen),
            matchesGoldenFile('goldens/library_${section.id}_$name.png'));
      });
    }
  }

  testWidgets('each library shows the shelves its frame lists', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<ContentRepository>(MockContentRepository());
    Get.lazyPut(
      () => LibraryController(
        Get.find<ContentRepository>(),
        LibrarySection.meditation,
      ),
    );

    await pumpScreen(tester, const LibraryScreen());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    for (final shelf in LibrarySection.meditation.shelves) {
      expect(find.text(shelf), findsOneWidget, reason: '$shelf is missing');
    }
  });

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('schedule, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.lazyPut(ScheduleController.new);

      await pumpScreen(tester, const ScheduleScreen(), brightness: brightness);

      await expectLater(find.byType(ScheduleScreen),
          matchesGoldenFile('goldens/schedule_$name.png'));
    });
  }
}
