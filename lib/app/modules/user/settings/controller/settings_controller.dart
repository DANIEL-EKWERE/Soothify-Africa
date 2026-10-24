import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../core/utils/image_picking.dart';
import '../../../../data/models/settings_entry.dart';
import '../../../../data/models/user_profile.dart';
import '../../../../data/models/user_role.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../../auth/language/controller/language_controller.dart';
import '../policy_screen.dart';
import '../../../../data/services/session_service.dart';
import '../../../../data/services/theme_service.dart';
import '../../../../widgets/confirm_dialog.dart';

/// Backs Settings — Figma "Profile/setting" (135:26963).
class SettingsController extends BaseController {
  SettingsController(this._theme, this._session, this._profiles, this._auth);

  final ThemeService _theme;
  final SessionService _session;
  final ProfileRepository _profiles;
  final AuthRepository _auth;

  /// The account as the server has it. Null until it has been read, and for
  /// a guest, who has none.
  final Rxn<UserProfile> profile = Rxn<UserProfile>();

  bool get isPractitioner => _session.isPractitioner;

  /// The list for whoever is signed in — see [SettingsEntry.forExpert].
  List<SettingsEntry> get entries => _session.isPractitioner
      ? SettingsEntry.forExpert
      : SettingsEntry.forClient;

  /// The account's own name, with the frame's placeholder behind it for a
  /// guest and for the moment before the profile has been read.
  String get displayName {
    final name = profile.value?.fullName ?? '';
    // "Guest" rather than a placeholder name: somebody browsing without an
    // account has no name here, and inventing one was what this screen used
    // to do.
    return name.isEmpty ? 'Guest' : name.split(RegExp(r'\s+')).first;
  }

  String get version => 'Version 1.0';

  /// The name that prints under the avatar.
  String get fullName {
    final name = profile.value?.fullName ?? '';
    return name.isEmpty ? 'User Profile' : name;
  }

  /// The portrait on the account, or empty for the asset the screen falls
  /// back to.
  String get avatarUrl => profile.value?.avatarUrl ?? '';

  @override
  void onInit() {
    super.onInit();
    _readProfile();
  }

  Future<void> _readProfile() async {
    if (_session.isGuest) return;
    final me = await guard(() => _profiles.me(), showFeedback: false);
    if (me == null) return;
    profile.value = me;
    if (name.text.isEmpty) name.text = me.fullName;
  }

  /// What the Update Account field shows when it is empty — the design puts
  /// the name already on the account there as a hint, not as a value.
  String get firstName => fullName.split(' ').first;

  /// The one field on Update Account.
  final TextEditingController name = TextEditingController();

  @override
  void onClose() {
    name.dispose();
    super.onClose();
  }

  /// "Update" on Update Account: saves the name.
  Future<void> updateAccount() async {
    final typed = name.text.trim();
    if (typed.isEmpty || typed == profile.value?.fullName) {
      Get.back();
      return;
    }

    final saved = await guard(() => _profiles.update(fullName: typed));
    if (saved == null) return;

    profile.value = saved;
    Get.back();
    AppFeedback.info('Saved.');
  }

  /// Save Changes on the profile screen. The same one field, from the other
  /// frame that offers it.
  Future<void> saveProfile() => updateAccount();

  /// The photo-source sheet on `259:37567`.
  ///
  /// Both sources end in the same place: a file on the device, uploaded and
  /// stored privately, read back as a signed link.
  Future<void> pickPhoto(String source) async {
    final picked = await _pickImage(
      source.toLowerCase().contains('camera')
          ? ImageSource.camera
          : ImageSource.gallery,
    );
    if (picked == null) return;

    final saved = await guard(() => _profiles.uploadAvatar(picked));
    if (saved == null) return;

    profile.value = saved;
    AppFeedback.info('Your photo is updated.');
  }

  /// Replaceable, so a test does not need a camera.
  Future<String?> Function(ImageSource source) _pickImage = pickImageFromDevice;

  // ignore: use_setters_to_change_properties
  void usePicker(Future<String?> Function(ImageSource source) picker) =>
      _pickImage = picker;

  bool isDark(BuildContext context) => _theme.isDark(context);

  Future<void> toggleTheme(BuildContext context) => _theme.toggle(context);

  /// Every row now opens the frame behind it. The six that used to answer
  /// with "not built yet" all had screens in the file — `259:37602`
  /// (subscription), `259:37589` (account), `259:37526` (notifications) and
  /// the three content pages — they had simply never been wired up.
  Future<void> open(SettingsEntry entry) async {
    switch (entry) {
      case SettingsEntry.careProtection:
        Get.toNamed(AppRoutes.careProtection);
      case SettingsEntry.manageSubscription:
        await Get.toNamed(AppRoutes.manageSubscription);
      case SettingsEntry.account:
        await Get.toNamed(AppRoutes.accountSettings);
      case SettingsEntry.favourites:
        await Get.toNamed(AppRoutes.favourites);
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

  /// "Edit Account Details" on Account Settings — the name, on its own
  /// screen. The portrait is changed on [AppRoutes.userProfile], which the
  /// avatar in Settings opens.
  void openEditAccount() => Get.toNamed(AppRoutes.updateAccount);

  /// The avatar in Settings, which wears an edit badge.
  void openUserProfile() => Get.toNamed(AppRoutes.userProfile);

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
    // The refresh token goes back so the server can retire it; this device
    // forgets its tokens either way, because an unreachable server must not
    // be able to keep somebody signed in.
    await _auth.signOut();
    await _session.signOut();
    await Get.offAllNamed(AppRoutes.shell);
  }

  /// Debug builds only — see [_ExpertModeDoor] in the screen.
  ///
  /// Saves the practitioner role and opens that side of the app. An
  /// approved application is what grants the role for real; this exists so
  /// those screens can be walked without one.
  Future<void> enterExpertMode() async {
    await _session.setRole(UserRole.practitioner);
    await Get.offAllNamed(AppRoutes.practitionerDashboard);
  }

  /// What the delete screen's red button does.
  ///
  /// The server asks for proof it is them -- their password, or for an
  /// account opened with Google or Apple, their address -- so this asks for
  /// it here rather than deleting on a tap. This is the one action in the
  /// app that cannot be taken back, and a phone left unlocked on a table
  /// should not be enough to do it.
  Future<void> confirmDeleteAccount() async {
    final context = Get.context;
    if (context == null) return;

    final proof = await _askForProof(context);
    if (proof == null || proof.isEmpty) return;

    final done = await guard(() async {
      await _auth.deleteAccount(proof);
      return true;
    });
    if (done != true) return;

    await _session.signOut();
    await Get.offAllNamed(AppRoutes.shell);
    AppFeedback.info(
      'Your account is closed and your journal, check-ins and profile are '
      'erased.',
    );
  }

  /// The password, or the address for an account with no password.
  Future<String?> _askForProof(BuildContext context) {
    final field = TextEditingController();
    // Google and Apple accounts have no password, so the server asks for
    // the address instead. It says which when the profile is read.
    final social = !(profile.value?.hasPassword ?? true);

    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete your account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              social
                  ? 'Type your email address to confirm. This cannot be '
                      'undone.'
                  : 'Enter your password to confirm. This cannot be undone.',
            ),
            SizedBox(height: 12.v),
            TextField(
              controller: field,
              obscureText: !social,
              autofocus: true,
              decoration: InputDecoration(
                hintText: social ? 'you@example.com' : 'Your password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<String>(result: null),
            child: const Text('Keep my account'),
          ),
          TextButton(
            onPressed: () => Get.back<String>(result: field.text.trim()),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

}
