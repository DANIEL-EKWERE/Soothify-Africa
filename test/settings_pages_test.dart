import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'dart:io';

import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';
import 'package:soothifyafrica/app/modules/user/settings/settings_screen.dart';
import 'package:soothifyafrica/app/data/models/notification_preference.dart';
import 'package:soothifyafrica/app/data/models/settings_entry.dart';
import 'package:soothifyafrica/app/data/models/user_role.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/data/services/theme_service.dart';
import 'package:soothifyafrica/app/modules/user/settings/account_settings_screen.dart';
import 'package:soothifyafrica/app/modules/user/settings/controller/notification_settings_controller.dart';
import 'package:soothifyafrica/app/modules/user/settings/controller/settings_controller.dart';
import 'package:soothifyafrica/app/modules/user/settings/delete_account_screen.dart';
import 'package:soothifyafrica/app/modules/user/settings/notification_settings_screen.dart';
import 'package:soothifyafrica/app/modules/user/settings/policy_screen.dart';
import 'package:soothifyafrica/app/modules/user/settings/user_profile_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/settings_pages_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<void> putSettings() async {
    await PrefUtils().init();
    Get.put(ThemeService());
    Get.put(SessionService());
    Get.put(SettingsController(Get.find<ThemeService>(),
        Get.find<SessionService>()));
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('settings pages, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      await putSettings();
      Get.put(NotificationSettingsController());

      for (final (label, screen) in <(String, Widget)>[
        ('account_settings', const AccountSettingsScreen()),
        ('delete_account', const DeleteAccountScreen()),
        ('notification_settings', const NotificationSettingsScreen()),
        ('user_profile', const UserProfileScreen()),
      ]) {
        await pumpScreen(tester, screen, brightness: brightness);
        await tester.pumpAndSettle();
        await expectLater(find.byWidget(screen),
            matchesGoldenFile('goldens/${label}_$name.png'));
      }
    });
  }

  testWidgets('every Settings row opens its screen, none toast',
      (tester) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    await putSettings();

    // A real route table, so `open` is exercised as it runs rather than
    // asserted against a mirror of itself.
    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          builder: (context, widget) {
            PrimaryColors.syncFrom(context);
            return widget!;
          },
          home: const SettingsScreen(),
          getPages: [
            for (final route in const [
              AppRoutes.manageSubscription,
              AppRoutes.accountSettings,
              AppRoutes.notificationSettings,
              AppRoutes.policy,
              AppRoutes.language,
              AppRoutes.expertApplication,
            ])
              GetPage(name: route, page: () => const SizedBox.shrink()),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final controller = Get.find<SettingsController>();
    const expected = {
      SettingsEntry.manageSubscription: AppRoutes.manageSubscription,
      SettingsEntry.account: AppRoutes.accountSettings,
      SettingsEntry.notifications: AppRoutes.notificationSettings,
      SettingsEntry.privacyPolicy: AppRoutes.policy,
      SettingsEntry.terms: AppRoutes.policy,
      SettingsEntry.about: AppRoutes.policy,
      SettingsEntry.changeLanguage: AppRoutes.language,
      SettingsEntry.becomeExpert: AppRoutes.expertApplication,
    };

    for (final entry in expected.entries) {
      unawaited(controller.open(entry.key));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, entry.value, reason: entry.key.label);
      // Nothing should have been answered with a "not built yet" toast.
      expect(find.textContaining('not built yet'), findsNothing,
          reason: entry.key.label);
      Get.back();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('logging out asks first, and cancelling keeps the session',
      (tester) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    await putSettings();

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          builder: (context, widget) {
            PrimaryColors.syncFrom(context);
            return widget!;
          },
          home: const SettingsScreen(),
          getPages: [
            GetPage(name: AppRoutes.shell, page: () => const SizedBox.shrink()),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final controller = Get.find<SettingsController>();
    unawaited(controller.logout());
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsOneWidget);

    // Cancel leaves everything where it was.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsNothing);
    expect(Get.currentRoute, isNot(AppRoutes.shell));

    // Confirming goes through.
    unawaited(controller.logout());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.shell);
  });

  testWidgets('the temporary door saves the role and opens the expert app',
      (tester) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    await putSettings();

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          builder: (context, widget) {
            PrimaryColors.syncFrom(context);
            return widget!;
          },
          home: const SettingsScreen(),
          getPages: [
            GetPage(
              name: AppRoutes.practitionerDashboard,
              page: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final door = find.text('Open expert mode (temporary)');
    await tester.dragUntilVisible(
      door,
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(door);
    await tester.pumpAndSettle();

    // Both halves matter: without the saved role the next launch sends the
    // user straight back to the client shell.
    expect(Get.find<SessionService>().role.value, UserRole.practitioner);
    expect(Get.currentRoute, AppRoutes.practitionerDashboard);
  });

  test('the rows are in the order the screen draws them', () {
    expect(
      SettingsEntry.values.map((e) => e.label),
      [
        'Manage subscription',
        'Account',
        'Light Mode',
        'Change Language',
        'Notifications',
        'Become an Expert',
        'Privacy Policy',
        'Terms & Conditions',
        'About Us',
        'Logout',
      ],
    );
  });

  test('every Settings glyph is drawn, not filled', () {
    // The row tints the whole file with the body ink, so a solid shape in
    // one becomes a blob beside nine outlines. Two did: the logout disc and
    // the rating star standing in for "Become an Expert".
    for (final entry in SettingsEntry.values) {
      final svg = File(entry.asset).readAsStringSync();
      final solidFills = RegExp(r'fill="#[0-9A-Fa-f]{3,8}"')
          .allMatches(svg)
          .length;
      // The bulb and the two arrows are strokes converted to filled paths by
      // the exporter; those draw as outlines. What must not appear is a
      // background plate behind the glyph.
      expect(svg, isNot(contains('rect width="24" height="24"')),
          reason: '${entry.label} carries a background plate');
      expect(solidFills, lessThanOrEqualTo(1), reason: entry.label);
    }
  });

  testWidgets('the notification switches persist', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    final controller = Get.put(NotificationSettingsController());

    await pumpScreen(tester, const NotificationSettingsScreen());
    await tester.pumpAndSettle();

    // The frame draws all four off.
    for (final p in NotificationPreference.values) {
      expect(controller.isOn(p), isFalse);
    }

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(controller.isOn(NotificationPreference.balance), isTrue);
    expect(
      PrefUtils().notificationPreference(NotificationPreference.balance.key),
      isTrue,
    );

    // A fresh controller reads the stored value back.
    final reopened = NotificationSettingsController()..onInit();
    expect(reopened.isOn(NotificationPreference.balance), isTrue);
  });

  test('no content page borrows the Delete Account copy', () {
    // All three frames are a copy of Delete Account with the heading swapped,
    // so none of that text is reproduced under them.
    for (final page in PolicyPage.values) {
      for (final section in PolicyScreen.body[page] ?? const []) {
        for (final paragraph in section.paragraphs) {
          expect(paragraph, isNot(contains('sorry to see you go')));
          expect(paragraph, isNot(contains('irreversible')));
        }
      }
    }
    expect(PolicyScreen.pending, isNot(contains('sorry to see you go')));
    expect(DeleteAccountScreen.lead, contains('sorry to see you go'));
  });

  test('all three content pages carry the copy the designer supplied', () {
    // Nothing falls back to the holding line any more.
    for (final page in PolicyPage.values) {
      expect(PolicyScreen.body[page], isNotNull, reason: page.title);
      expect(PolicyScreen.body[page], isNotEmpty, reason: page.title);
    }
    expect(
      PolicyScreen.body[PolicyPage.about]!.map((s) => s.heading),
      ['Our Vision', 'Mindful Craftsmanship'],
    );
    // Both documents run to six numbered sections under their opening block.
    expect(PolicyScreen.body[PolicyPage.terms], hasLength(7));
    expect(PolicyScreen.body[PolicyPage.privacy], hasLength(7));
    expect(PolicyScreen.lastUpdated[PolicyPage.terms], isNotNull);
    expect(PolicyScreen.lastUpdated[PolicyPage.privacy], isNotNull);
    // About Us came without a date line, and must not invent one.
    expect(PolicyScreen.lastUpdated[PolicyPage.about], isNull);
  });

  testWidgets('each content page renders its own document', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();

    for (final page in PolicyPage.values) {
      await pumpScreen(tester, PolicyScreen(only: page));
      expect(find.text(page.title), findsOneWidget);
      // Nothing falls back to the holding line.
      expect(find.text(PolicyScreen.pending), findsNothing, reason: page.title);
      // The first heading of that page's own document, and no other page's.
      expect(find.text(PolicyScreen.body[page]!.first.heading), findsOneWidget,
          reason: page.title);
      for (final other in PolicyPage.values.where((p) => p != page)) {
        expect(find.text(PolicyScreen.body[other]!.first.heading), findsNothing,
            reason: '${page.title} showed ${other.title}');
      }
    }
  });
}
