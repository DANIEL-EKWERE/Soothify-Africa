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
import 'package:soothifyafrica/app/data/models/profile_stats.dart';
import 'package:soothifyafrica/app/data/models/user_profile.dart';
import 'package:soothifyafrica/app/data/repositories/auth_repository.dart';
import 'package:soothifyafrica/app/data/repositories/profile_repository.dart';
import 'package:soothifyafrica/app/data/models/user_role.dart';

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
    final session = await SessionService().init();
    // Signed in: Settings reads the account, and a guest has none to read.
    await session.setRole(UserRole.user);
    Get.put<SessionService>(session);
    // The screen reads the account now. Seeded with the frame's own name,
    // which is what these goldens were recorded against -- the app itself
    // takes it from the server.
    Get.put<ProfileRepository>(_NamedProfile('Dera Ochukwu'));
    Get.put<AuthRepository>(StubAuthRepository());
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
      // The account is read when the screen opens.
      await settleLoads(tester);

      await expectLater(find.byType(SettingsScreen),
          matchesGoldenFile('goldens/settings_$name.png'));
    });
  }

  testWidgets('every row the design lists is rendered', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await boot();

    await pumpScreen(tester, const SettingsScreen());

    // The client's list: the expert's carries a protection hub this
    // screen does not show for a signed-in user.
    for (final entry in SettingsEntry.forClient) {
      expect(find.text(entry.label), findsOneWidget,
          reason: '${entry.label} is missing from Settings');
    }
    expect(find.text('Version 1.0'), findsOneWidget);
  });
}

/// A profile with a name on it, and nothing else to say.
class _NamedProfile implements ProfileRepository {
  _NamedProfile(this.name);

  final String name;

  @override
  Future<ProfileStats> getStats() async => ProfileStats.empty;

  @override
  Future<UserProfile> me() async => UserProfile(id: '1', fullName: name);

  @override
  Future<UserProfile> update({
    String? fullName,
    String? language,
    String? moodFigure,
    String? communityHandle,
  }) async =>
      UserProfile(id: '1', fullName: fullName ?? name);

  @override
  Future<UserProfile> uploadAvatar(String filePath) async =>
      UserProfile(id: '1', fullName: name, avatarUrl: filePath);
}
