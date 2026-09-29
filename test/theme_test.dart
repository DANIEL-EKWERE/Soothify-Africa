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
    test('defaults to light, not to the system setting', () async {
      final service = await ThemeService().init();
      // The design is drawn light-first, so a phone set to dark must not open
      // the app dark before the user has chosen anything.
      expect(service.mode.value, ThemeMode.light);
    });

    test('a stored system preference is still honoured', () async {
      await (await ThemeService().init()).setMode(ThemeMode.system);
      expect((await ThemeService().init()).mode.value, ThemeMode.system);
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

  testWidgets('toggling repaints what is already on screen', (tester) async {
    // The regression this covers: `appTheme` is a plain static, so reading it
    // subscribes to nothing. Toggling rebuilt the MaterialApp and nothing
    // beneath it, and the change only appeared after the app was killed and
    // reopened. The old test above mounted a *fresh* tree per mode, so it
    // passed throughout.
    final service = Get.put(await ThemeService().init());

    await tester.pumpWidget(
      Obx(
        () => GetMaterialApp(
          theme: theme,
          darkTheme: darkTheme,
          themeMode: service.mode.value,
          builder: (context, child) {
            // Mirrors main.dart: resolved from the service, not from
            // `Theme.of`, which reports the pre-toggle brightness for the
            // first half of the theme animation.
            PrimaryColors.active = PrimaryColors.of(
              service.isDark(context) ? Brightness.dark : Brightness.light,
            );
            return child!;
          },
          home: Builder(
            builder: (_) => ColoredBox(
              color: appTheme.background,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    ColoredBox painted() => tester.widget<ColoredBox>(
          find.byType(ColoredBox).last,
        );
    expect(painted().color, PrimaryColors.light.background);

    await service.setMode(ThemeMode.dark);
    await tester.pumpAndSettle();

    expect(painted().color, PrimaryColors.dark.background,
        reason: 'a mounted screen must repaint without being rebuilt by hand');
    expect(appTheme.background, PrimaryColors.dark.background);

    await service.setMode(ThemeMode.light);
    await tester.pumpAndSettle();
    expect(painted().color, PrimaryColors.light.background);
  });
}
