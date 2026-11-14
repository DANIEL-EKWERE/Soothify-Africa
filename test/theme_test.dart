import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/l10n/app_translations.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';

import 'package:soothifyafrica/app/data/models/app_language.dart';
import 'package:soothifyafrica/app/data/services/theme_service.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  group('palettes', () {
    test('ink on a surface that stays white stays dark too', () {
      // `onPrimary` is white in both palettes: it is the fill of a surface
      // that does not follow the theme -- the guest Sign up button, the
      // wellness guide's close disc, a badge on a gradient card. Anything
      // written on one of those has to come from a token that also stays
      // put, which is what `onFixedLight` is for.
      //
      // The bug this guards: those labels were coloured `textPrimary`, which
      // flips to near-white in the dark palette, so they went white on white
      // -- on the signed-out Profile the person glyph kept its own dark fill
      // and the words beside it simply were not there.
      for (final palette in [PrimaryColors.light, PrimaryColors.dark]) {
        expect(palette.onPrimary, PrimaryColors.light.onPrimary,
            reason: 'onPrimary is a fixed white surface');
        expect(palette.onFixedLight, PrimaryColors.light.onFixedLight,
            reason: 'onFixedLight is the ink for one');
        expect(
          _contrast(palette.onFixedLight, palette.onPrimary),
          greaterThan(4.5),
          reason: 'onFixedLight must be readable on onPrimary',
        );
      }

      // And the token that must not be used there really does flip, so the
      // check above keeps meaning something.
      expect(PrimaryColors.dark.textPrimary,
          isNot(PrimaryColors.light.textPrimary));
      expect(
        _contrast(PrimaryColors.dark.textPrimary, PrimaryColors.dark.onPrimary),
        lessThan(4.5),
        reason: 'textPrimary on a white surface is the mistake being guarded',
      );
    });

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
        // The same catalogue the app registers. Without it `.tr` answers
        // with the key, so a screen under test reads "nav.home" where the
        // app reads "Home".
        translations: AppTranslations(),
        locale: AppLanguage.english.locale,
        fallbackLocale: AppLanguage.english.locale,
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
        // The same catalogue the app registers. Without it `.tr` answers
        // with the key, so a screen under test reads "nav.home" where the
        // app reads "Home".
        translations: AppTranslations(),
        locale: AppLanguage.english.locale,
        fallbackLocale: AppLanguage.english.locale,
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

/// WCAG relative luminance, and the contrast ratio built from it.
///
/// Spelled out rather than pulled in: the only thing asked of it is whether
/// two colours can be told apart, and 4.5 is the ratio body text needs.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) +
      0.7152 * channel(c.g) +
      0.0722 * channel(c.b);
}

double _contrast(Color a, Color b) {
  final (x, y) = (_luminance(a), _luminance(b));
  final (hi, lo) = x > y ? (x, y) : (y, x);
  return (hi + 0.05) / (lo + 0.05);
}
