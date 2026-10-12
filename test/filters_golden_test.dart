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
import 'package:soothifyafrica/app/widgets/filter_glyph.dart';
import 'package:soothifyafrica/app/widgets/filter_menu.dart';

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

  /// The selected variants in the file — More Filters `259:30410`, Style
  /// `259:30732` — outline the chip in soothify blue and leave the fill and
  /// the label alone. It used to fill the chip instead.
  testWidgets('a ticked chip is outlined, not filled', (tester) async {
    await mount(
      tester,
      FilterKind.more,
      initial: FilterSelection()..toggle(FilterGroup.focus, 'Basics'),
    );

    BoxDecoration decorationOf(String label) {
      final box = tester.widget<Container>(
        find.ancestor(of: find.text(label), matching: find.byType(Container)),
      );
      return box.decoration! as BoxDecoration;
    }

    final ticked = decorationOf('Basics');
    final plain = decorationOf('Morning');

    expect(ticked.border!.top.color, appTheme.soothifyBlue);
    expect(plain.border!.top.color, appTheme.filterChipBorder);
    // The fill does not move, which is what makes the outline readable.
    expect(ticked.color, plain.color);
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
  testWidgets('the glyph drops a menu and the chosen sheet applies back', (
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

    // The glyph opens the menu, not a sheet.
    await tester.tap(find.byType(FilterGlyph));
    await tester.pumpAndSettle();
    expect(find.byType(FiltersScreen), findsNothing);
    for (final (label, _) in filterMenuItems) {
      expect(find.text(label), findsOneWidget, reason: '$label is missing');
    }

    await tester.tap(find.text('Duration'));
    await tester.pumpAndSettle();
    expect(find.byType(FiltersScreen), findsOneWidget);

    await tester.tap(find.text('20 minutes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.byType(FiltersScreen), findsNothing);
    expect(find.byType(LibraryScreen), findsOneWidget);
    expect(library.filters.value.count, 1);
    expect(
      library.filters.value.isSelected(FilterGroup.duration, '20 minutes'),
      isTrue,
    );

    // And the sheet's controller went with it.
    expect(Get.isRegistered<FiltersController>(), isFalse);

    // Reopening seeds the next sheet from what is applied, so a second trip
    // adds to the selection rather than replacing it.
    await tester.tap(find.byType(FilterGlyph));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Style'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mindfulness'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(library.filters.value.count, 2);
    expect(
      library.filters.value.isSelected(FilterGroup.style, 'Mindfulness'),
      isTrue,
    );
  });

  /// The menu is its own designed surface — a card hung off the glyph,
  /// overlapping the search row — so it is worth a picture of its own.
  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('the glyph menu, $name', (tester) async {
      useDesignFrame(tester);
      disableMotion(tester);
      await loadAppFonts();
      Get.put<ContentRepository>(MockContentRepository());
      Get.put(
        LibraryController(
          Get.find<ContentRepository>(),
          LibrarySection.balance,
        ),
      );

      await tester.pumpWidget(
        Sizer(
          builder: (_, _, _) => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            darkTheme: darkTheme,
            themeMode: brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
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
      // The mock shelves answer after 400ms; without waiting them out the
      // test ends on a pending timer.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      await precacheAll(tester, find.byType(LibraryScreen), libraryCovers);

      await tester.tap(find.byType(FilterGlyph));
      await tester.pumpAndSettle();

      // The whole app, not the LibraryScreen: the menu is a route of its
      // own in the overlay, so it is not inside the screen's subtree.
      await expectLater(
        find.byType(GetMaterialApp),
        matchesGoldenFile('goldens/filter_menu_$name.png'),
      );
    });
  }

  testWidgets('dismissing the menu opens nothing', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<ContentRepository>(MockContentRepository());
    Get.put(
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

    await tester.tap(find.byType(FilterGlyph));
    await tester.pumpAndSettle();
    // Anywhere off the card: the barrier takes the tap.
    await tester.tapAt(const Offset(30, 700));
    await tester.pumpAndSettle();

    expect(find.text('More filters'), findsNothing);
    expect(find.byType(FiltersScreen), findsNothing);
  });

  /// Approach is the fourth row in the menu and the one frame the file never
  /// drew. It must still land somewhere.
  testWidgets('Approach opens a sheet that says it is unfinished', (
    tester,
  ) async {
    await mount(tester, FilterKind.approach);

    expect(find.text('Approach'), findsOneWidget);
    expect(find.textContaining('on the way'), findsOneWidget);
    expect(Get.find<FiltersController>().canApply, isFalse);
  });

  /// The frames close every odd chip group with "See More...", which opens
  /// nothing. It is not shipped.
  testWidgets('no sheet carries a See More link', (tester) async {
    for (final kind in FilterKind.values) {
      await mount(tester, kind);
      expect(
        find.textContaining('See More'),
        findsNothing,
        reason: '${kind.name} still has one',
      );
      Get.reset();
    }
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

    await tester.tap(find.byType(FilterGlyph));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duration'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 minutes'));
    await tester.pumpAndSettle();

    Get.back();
    await tester.pumpAndSettle();

    expect(library.filters.value.isEmpty, isTrue);
  });
}
