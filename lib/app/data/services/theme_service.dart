import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/pref_utils.dart';

/// Owns the light/dark preference and persists it.
///
/// A [GetxService] because the choice must outlive every route. The palette
/// itself is resolved by `PrimaryColors.syncFrom` in the app builder — this
/// service only decides which [ThemeMode] is in force.
class ThemeService extends GetxService {
  final Rx<ThemeMode> mode = ThemeMode.system.obs;

  Future<ThemeService> init() async {
    // Idempotent; guarantees preferences are loaded even if this service
    // is constructed before main() initialises them (as in tests).
    await PrefUtils().init();
    mode.value = _decode(PrefUtils().getThemeMode());
    return this;
  }

  bool isDark(BuildContext context) => switch (mode.value) {
        ThemeMode.dark => true,
        ThemeMode.light => false,
        ThemeMode.system =>
          MediaQuery.platformBrightnessOf(context) == Brightness.dark,
      };

  Future<void> setMode(ThemeMode value) async {
    mode.value = value;
    await PrefUtils().setThemeMode(_encode(value));
    Get.changeThemeMode(value);
  }

  /// Flips between light and dark, resolving "system" against what is
  /// currently on screen so the first tap always visibly changes something.
  Future<void> toggle(BuildContext context) =>
      setMode(isDark(context) ? ThemeMode.light : ThemeMode.dark);

  static ThemeMode _decode(String? value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _encode(ThemeMode value) => switch (value) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}
