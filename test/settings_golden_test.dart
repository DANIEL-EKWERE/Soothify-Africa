import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/settings_entry.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/data/services/theme_service.dart';
import 'package:soothifyafrica/app/modules/user/settings/binding/settings_binding.dart';
import 'package:soothifyafrica/app/modules/user/settings/settings_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/settings_golden_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  /// Registers the services first, the way `main()` does, then the controller
  /// through the real binding — rather than hand-building the controller,
  /// which left it unregistered by the time the screen built.
  Future<void> boot() async {
    Get.put<ThemeService>(await ThemeService().init());
    Get.put<SessionService>(await SessionService().init());
    SettingsBinding().dependencies();
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('settings, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      await boot();

      await pumpScreen(tester, const SettingsScreen(), brightness: brightness);

      await expectLater(find.byType(SettingsScreen),
          matchesGoldenFile('goldens/settings_$name.png'));
    });
  }

  testWidgets('every row the design lists is rendered', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await boot();

    await pumpScreen(tester, const SettingsScreen());

    for (final entry in SettingsEntry.values) {
      expect(find.text(entry.label), findsOneWidget,
          reason: '${entry.label} is missing from Settings');
    }
    expect(find.text('Version 1.0'), findsOneWidget);
  });
}
