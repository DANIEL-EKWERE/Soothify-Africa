import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/settings_entry.dart';
import '../../../../data/models/user_role.dart';
import '../../../auth/language/controller/language_controller.dart';
import '../policy_screen.dart';
import '../../../../data/services/session_service.dart';
import '../../../../data/services/theme_service.dart';
import '../../../../widgets/confirm_dialog.dart';

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

  /// The name "User Profile" prints under the avatar — the frame's own.
  String get fullName => 'Dera Ochukwu';

  /// Nothing persists a profile yet, so Save Changes returns rather than
  /// claiming to have saved.
  void saveProfile() => Get.back();

  /// The photo-source sheet on `259:37567`. No picker is wired up.
  void pickPhoto(String source) =>
      AppFeedback.info('$source is not connected yet.');

  bool isDark(BuildContext context) => _theme.isDark(context);

  Future<void> toggleTheme(BuildContext context) => _theme.toggle(context);

  /// Every row now opens the frame behind it. The six that used to answer
  /// with "not built yet" all had screens in the file — `259:37602`
  /// (subscription), `259:37589` (account), `259:37526` (notifications) and
  /// the three content pages — they had simply never been wired up.
  Future<void> open(SettingsEntry entry) async {
    switch (entry) {
      case SettingsEntry.manageSubscription:
        await Get.toNamed(AppRoutes.manageSubscription);
      case SettingsEntry.account:
        await Get.toNamed(AppRoutes.accountSettings);
      case SettingsEntry.notifications:
        await Get.toNamed(AppRoutes.notificationSettings);
      case SettingsEntry.privacyPolicy:
        await Get.toNamed(AppRoutes.policy, arguments: PolicyPage.privacy);
      case SettingsEntry.terms:
        await Get.toNamed(AppRoutes.policy, arguments: PolicyPage.terms);
      case SettingsEntry.about:
        await Get.toNamed(AppRoutes.policy, arguments: PolicyPage.about);
      case SettingsEntry.changeLanguage:
        // Without this the screen finishes onboarding's way: `offAllNamed` to
        // the KYC, which dropped the user on the age question.
        await Get.toNamed(AppRoutes.language,
            arguments: LanguageEntry.settings);
      case SettingsEntry.becomeExpert:
        await Get.toNamed(AppRoutes.expertApplication);
      case SettingsEntry.logout:
        await logout();
      case SettingsEntry.themeToggle:
        // Handled by the row's switch, not by tapping the row.
        break;
    }
  }

  /// "Unlock Soothify Pro" on `259:37602`.
  void openPlans() => Get.toNamed(AppRoutes.subscriptionOffer);

  void openEditAccount() => Get.toNamed(AppRoutes.userProfile);

  void openDeleteAccount() => Get.toNamed(AppRoutes.deleteAccount);

  /// Signing out drops the session and resets the stack, so it asks first.
  ///
  /// The dialog needs a context; [Get.context] is the one the app is built
  /// with. If there is none — only in a test that never pumped a widget — the
  /// sign-out goes ahead rather than silently doing nothing.
  Future<void> logout() async {
    final context = Get.context;
    if (context != null) {
      final go = await ConfirmDialog.confirmed(
        context,
        title: 'Log out?',
        message: 'You will need to sign in again to reach your sessions, '
            'journal and saved content.',
        confirmLabel: 'Log out',
      );
      if (!go) return;
    }
    await _session.signOut();
    await Get.offAllNamed(AppRoutes.shell);
  }

  /// TEMPORARY — see [_ExpertModeDoor] in the screen.
  ///
  /// Saves the practitioner role and opens that side of the app, which is
  /// exactly what `/role` does; the difference is that this one is reachable.
  /// Remove both once an approved application grants the role.
  Future<void> enterExpertMode() async {
    await _session.setRole(UserRole.practitioner);
    await Get.offAllNamed(AppRoutes.practitionerDashboard);
  }

  /// Nothing deletes an account yet, and this is the one action in Settings
  /// that cannot be taken back, so it says so rather than appearing to work.
  void confirmDeleteAccount() =>
      AppFeedback.info('Account deletion is not connected yet.');
}
