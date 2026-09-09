import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/data/models/library_section.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/modules/user/library/controller/library_controller.dart';
import 'package:soothifyafrica/app/modules/user/library/library_screen.dart';
import 'package:soothifyafrica/app/routes/app_pages.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';
import 'package:soothifyafrica/app/data/models/media_filter.dart';
import 'package:soothifyafrica/app/modules/user/filters/controller/filters_controller.dart';
import 'package:soothifyafrica/app/modules/user/filters/filters_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/filters_golden_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<void> mount(
    WidgetTester tester,
    FilterKind kind, {
    Brightness brightness = Brightness.light,
    FilterSelection? initial,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(FiltersController(initial ?? FilterSelection()));
    await pumpScreen(tester, FiltersScreen(kind: kind), brightness: brightness);
  }

  for (final kind in FilterKind.values) {
    for (final (name, brightness) in [
      ('light', Brightness.light),
      ('dark', Brightness.dark),
    ]) {
      testWidgets('${kind.name}, $name', (tester) async {
        await mount(tester, kind, brightness: brightness);
        await expectLater(
          find.byType(FiltersScreen),
          matchesGoldenFile('goldens/filters_${kind.name}_$name.png'),
        );
      });
    }
  }

  testWidgets('every chip the frames draw is on screen', (tester) async {
    await mount(tester, FilterKind.more);

    for (final group in FilterGroup.more) {
      // The Music group holds a chip also called "Music", so that word is on
      // screen twice — the heading and the chip. That is the frame, not a
      // duplicate render.
      final twice = group.options.contains(group.label);
      expect(
        find.text(group.label),
        twice ? findsNWidgets(2) : findsOneWidget,
        reason: '${group.label} heading is missing',
      );
      for (final option in group.options) {
        expect(
          find.text(option),
          twice && option == group.label ? findsNWidgets(2) : findsOneWidget,
          reason: '$option is missing from ${group.label}',
        );
      }
    }
  });

  testWidgets('Style shows all seven cards with their descriptions', (
    tester,
  ) async {
    await mount(tester, FilterKind.style);

    for (final style in FilterStyle.all) {
      expect(find.text(style.title), findsOneWidget);
      expect(find.text(style.description), findsOneWidget);
    }
  });

  testWidgets('Apply is dead until something is ticked', (tester) async {
    await mount(tester, FilterKind.duration);
    final controller = Get.find<FiltersController>();

    expect(controller.canApply, isFalse);

    await tester.tap(find.text('15 minutes'));
    await tester.pumpAndSettle();

    expect(controller.canApply, isTrue);
    expect(controller.isSelected(FilterGroup.duration, '15 minutes'), isTrue);

    // And it unticks, so a filter can be taken off without leaving the sheet.
    await tester.tap(find.text('15 minutes'));
    await tester.pumpAndSettle();
    expect(controller.canApply, isFalse);
  });

  test('the design typos do not ship', () {
    final all = [for (final g in FilterGroup.values) ...g.options];
    expect(all, contains('Strength'));
    expect(all, isNot(contains('Strenght')));
    expect(all, contains('Immune System'));
    expect(all, isNot(contains('Immune Sysytem')));
    expect(all, contains('Small Stability Ball'));
    expect(all, isNot(contains('Small  Stability Ball')));
  });

  test('a duration chip is a bucket, not an exact length', () {
    final selection = FilterSelection()
      ..toggle(FilterGroup.duration, '10 minutes');

    // 12 minutes is nearer 10 than 15, so it belongs to the 10 bucket.
    expect(selection.matchesDuration(12 * 60), isTrue);
    expect(selection.matchesDuration(14 * 60), isFalse);
    // Nothing chosen lets everything through.
    expect(FilterSelection().matchesDuration(37 * 60), isTrue);
  });

  test('the working copy is not the library\'s own selection', () {
    final applied = FilterSelection()..toggle(FilterGroup.focus, 'Calm');
    final controller = FiltersController(applied);

    controller.toggle(FilterGroup.focus, 'Breath');

    // Backing out of the sheets must leave what was applied untouched.
    expect(applied.count, 1);
    expect(controller.count, 2);
  });

  /// The whole point of the sheets: the library's glyph opens them and what
  /// is applied comes back. The glyph used to raise "Filters are not built
  /// yet".
  testWidgets('the library glyph opens the sheets and takes the result back', (
    tester,
  ) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<ContentRepository>(MockContentRepository());
    final library = Get.put(
      LibraryController(Get.find<ContentRepository>(), LibrarySection.balance),
    );

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          getPages: AppPages.pages,
          builder: (context, widget) {
            PrimaryColors.syncFrom(context);
            return widget!;
          },
          home: const LibraryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    library.openFilters();
    await tester.pumpAndSettle();
    expect(find.byType(FiltersScreen), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);

    // Through to Style and back out again, carrying the tick with it.
    await tester.tap(find.text('20 minutes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Style'));
    await tester.pumpAndSettle();
    expect(find.text('Mindfulness'), findsOneWidget);

    await tester.tap(find.text('Mindfulness'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    // Applying from the deeper sheet unwinds the whole flow, not one level.
    expect(find.byType(FiltersScreen), findsNothing);
    expect(find.byType(LibraryScreen), findsOneWidget);
    expect(library.filters.value.count, 2);
    expect(
      library.filters.value.isSelected(FilterGroup.duration, '20 minutes'),
      isTrue,
    );
    expect(
      library.filters.value.isSelected(FilterGroup.style, 'Mindfulness'),
      isTrue,
    );

    // And the flow's controller went with it.
    expect(Get.isRegistered<FiltersController>(), isFalse);
  });

  testWidgets('backing out of the sheets changes nothing', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<ContentRepository>(MockContentRepository());
    final library = Get.put(
      LibraryController(
        Get.find<ContentRepository>(),
        LibrarySection.meditation,
      ),
    );

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          getPages: AppPages.pages,
          builder: (context, widget) {
            PrimaryColors.syncFrom(context);
            return widget!;
          },
          home: const LibraryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    library.openFilters();
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 minutes'));
    await tester.pumpAndSettle();

    Get.back();
    await tester.pumpAndSettle();

    expect(library.filters.value.isEmpty, isTrue);
  });
}
