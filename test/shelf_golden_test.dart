import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/modules/user/shelf/controller/shelf_controller.dart';
import 'package:soothifyafrica/app/modules/user/shelf/shelf_screen.dart';

import 'helpers.dart';

const _art = [
  'assets/images/content/cover_a.png',
  'assets/images/content/cover_b.png',
  'assets/images/content/cover_c.png',
  'assets/images/content/cover_d.png',
];

/// Regenerate with:
///   flutter test --update-goldens test/shelf_golden_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  void boot(String shelf) {
    Get.put<ContentRepository>(MockContentRepository());
    Get.lazyPut(() => ShelfController(Get.find<ContentRepository>(), shelf));
  }

  testWidgets('the grid lists the page behind a shelf', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    boot('Sounds');

    await pumpScreen(tester, const ShelfScreen());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final controller = Get.find<ShelfController>();
    // The frame lists ten cards, not the three or four a shelf previews.
    expect(controller.items.length, 10);
    expect(find.text('Sounds'), findsOneWidget);
    expect(find.text('Midnight Rainfall'), findsOneWidget);
    expect(find.text('Chiamaka Eze'), findsOneWidget);
  });

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('shelf grid, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      boot('Sounds');

      await pumpScreen(tester, const ShelfScreen(), brightness: brightness);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await precacheAll(tester, find.byType(ShelfScreen), _art);

      await expectLater(find.byType(ShelfScreen),
          matchesGoldenFile('goldens/shelf_$name.png'));
    });
  }
}
