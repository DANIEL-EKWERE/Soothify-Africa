import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/settings_entry.dart';
import '../../../../data/services/session_service.dart';
import '../../../../data/services/theme_service.dart';

/// Backs Settings — Figma "Profile/setting" (135:26963).
class SettingsController extends GetxController {
  SettingsController(this._theme, this._session);

  final ThemeService _theme;
  final SessionService _session;

  List<SettingsEntry> get entries => SettingsEntry.values;

  /// The design's own placeholder name. Nothing persists a display name yet —
  /// sign-up captures one but never stores it — so this is honest placeholder
  /// copy rather than a value read from an empty store.
  String get displayName => 'Dera';

  String get version => 'Version 1.0';

  bool isDark(BuildContext context) => _theme.isDark(context);

  Future<void> toggleTheme(BuildContext context) => _theme.toggle(context);

  Future<void> open(SettingsEntry entry) async {
    switch (entry) {
      case SettingsEntry.changeLanguage:
        await Get.toNamed(AppRoutes.language);
      case SettingsEntry.logout:
        await _session.signOut();
        await Get.offAllNamed(AppRoutes.signin);
      case SettingsEntry.themeToggle:
        // Handled by the row's switch, not by tapping the row.
        break;
      default:
        AppFeedback.info('${entry.label} is not built yet.');
    }
  }
}
