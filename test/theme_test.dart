import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';

import 'package:soothifyafrica/app/data/services/theme_service.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  group('palettes', () {
    test('both brightnesses are declared and distinct', () {
      expect(PrimaryColors.light.brightness, Brightness.light);
      expect(PrimaryColors.dark.brightness, Brightness.dark);
      expect(PrimaryColors.dark.isDark, isTrue);
      expect(
        PrimaryColors.dark.background,
        isNot(PrimaryColors.light.background),
      );
    });

    test('dark uses the charcoal A variant, not the rejected blue B', () {
      expect(PrimaryColors.dark.background, const Color(0xFF131414));
      expect(PrimaryColors.dark.surface, const Color(0xFF423F3F));
    });

    test('ThemeData is built per brightness', () {
      expect(theme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, PrimaryColors.light.background);
      expect(darkTheme.scaffoldBackgroundColor, PrimaryColors.dark.background);
    });

    test('text colours track the palette they were built from', () {
      // Regression guard: both ThemeData objects must be constructible
      // regardless of which palette is globally active.
      expect(theme.textTheme.bodyLarge?.color, PrimaryColors.light.textPrimary);
      expect(
        darkTheme.textTheme.bodyLarge?.color,
        PrimaryColors.dark.textPrimary,
      );
    });
  });

  group('ThemeService', () {
    test('defaults to following the system', () async {
      final service = await ThemeService().init();
      expect(service.mode.value, ThemeMode.system);
    });

    test('persists an explicit choice across restarts', () async {
      await (await ThemeService().init()).setMode(ThemeMode.dark);

      // A fresh service reads what the previous one saved.
      expect((await ThemeService().init()).mode.value, ThemeMode.dark);
    });
  });

  testWidgets('the global palette follows the rendered theme', (tester) async {
    for (final (mode, expected) in [
      (ThemeMode.light, PrimaryColors.light),
      (ThemeMode.dark, PrimaryColors.dark),
    ]) {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: theme,
          darkTheme: darkTheme,
          themeMode: mode,
          builder: (context, child) {
            PrimaryColors.syncFrom(context);
            return child!;
          },
          home: const SizedBox.shrink(),
        ),
      );
      await tester.pumpAndSettle();

      expect(appTheme.background, expected.background);
    }
  });
}
