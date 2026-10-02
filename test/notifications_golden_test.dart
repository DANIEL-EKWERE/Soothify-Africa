import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/app_notification.dart';
import 'package:soothifyafrica/app/data/repositories/mock_notification_repository.dart';
import 'package:soothifyafrica/app/data/repositories/notification_repository.dart';
import 'package:soothifyafrica/app/modules/user/notifications/controller/notifications_controller.dart';
import 'package:soothifyafrica/app/modules/user/notifications/notifications_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/notifications_golden_test.dart
const _art = [
  'assets/images/notifications/avatar_male.png',
  'assets/images/notifications/avatar_female.png',
  'assets/images/notifications/ic_reminder.png',
  'assets/images/notifications/ic_heart_filled.png',
];

/// Every row carries a relative timestamp, so "now" is pinned or the goldens
/// go stale by the hour.
DateTime _fixedNow() => DateTime(2026, 1, 8, 14, 30);

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<NotificationsController> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<NotificationRepository>(
      MockNotificationRepository(now: _fixedNow),
    );
    final controller = Get.put(
      NotificationsController(Get.find<NotificationRepository>(),
          now: _fixedNow),
    );
    await pumpScreen(tester, const NotificationsScreen(),
        brightness: brightness);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    return controller;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('notifications, $name', (tester) async {
      await mount(tester, brightness: brightness);
      await precacheAll(tester, find.byType(NotificationsScreen), _art);

      await expectLater(find.byType(NotificationsScreen),
          matchesGoldenFile('goldens/notifications_$name.png'));
    });
  }

  testWidgets('every shape the frame draws is on screen', (tester) async {
    await mount(tester);

    // A line with an avatar, one without, the outlined card, the digest and
    // the row with an inline action.
    expect(find.textContaining('Kendrick'), findsOneWidget);
    expect(find.textContaining('John'), findsOneWidget);
    // The outlined Reminder card, plus the two booking rows the second
    // frame labels the same way.
    expect(find.text('Reminder'), findsNWidgets(3));
    expect(find.textContaining('session today at 5:00pm'), findsNWidgets(2));
    expect(find.text('Your Weekly Mindful Quotes'), findsOneWidget);
    expect(find.textContaining('weekly mental health tip'), findsOneWidget);
    expect(find.text('New article posted'), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);

    // Five chips no longer fit across 342, so the row scrolls. They are all
    // laid out — clipped is not offstage — so all three are still found.
    for (final f in NotificationFilter.values) {
      expect(find.text(f.label), findsOneWidget);
    }
  });

  testWidgets('the chips narrow the list', (tester) async {
    final controller = await mount(tester);
    expect(controller.visible, hasLength(10));

    await tester.tap(find.text('Sessions'));
    await tester.pumpAndSettle();

    expect(controller.filter.value, NotificationFilter.sessions);
    // The three booking rows plus the Reminder card.
    expect(controller.visible, hasLength(4));
    expect(find.textContaining('Pilates & Core session tomorrow'),
        findsOneWidget);
    expect(find.textContaining('Kendrick'), findsNothing);

    await tester.tap(find.text("What's new"));
    await tester.pumpAndSettle();
    expect(controller.filter.value, NotificationFilter.whatsNew);
    expect(controller.visible, hasLength(6));
    expect(find.textContaining('Kendrick'), findsOneWidget);
    expect(find.textContaining('Yoga session on 28 Sep 2026'), findsNothing);

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(controller.visible, hasLength(10));
  });

  testWidgets("only What's new carries the New tag", (tester) async {
    await mount(tester);
    expect(find.text('New'), findsOneWidget);
    expect(
      NotificationFilter.values.where((f) => f.badge).toList(),
      [NotificationFilter.whatsNew],
    );
  });

  test('timestamps are computed, not the frame\'s typos', () {
    final now = DateTime(2026, 1, 8, 14, 30);
    AppNotification at(Duration ago) => AppNotification(
          id: 'x',
          kind: NotificationKind.plain,
          at: now.subtract(ago),
        );

    // The frame writes "45minutes ago" and "1 days ago".
    expect(at(const Duration(minutes: 45)).ago(now), '45 minutes ago');
    expect(at(const Duration(hours: 1)).ago(now), '1 hour ago');
    expect(at(const Duration(hours: 5)).ago(now), '5 hours ago');
    expect(at(const Duration(days: 1)).ago(now), 'Yesterday');
    expect(at(const Duration(days: 2)).ago(now), '2 days ago');
  });

  test('the unread marks match the frames', () async {
    final feed = await MockNotificationRepository(now: _fixedNow).feed();
    final unread = feed.where((n) => n.unread).map((n) => n.kind).toList();
    // `176:24737` dots only the Reminder card and the weekly digest;
    // `259:61271` dots its first two booking rows and not the third.
    expect(unread, [
      NotificationKind.reminder,
      NotificationKind.digest,
      NotificationKind.booking,
      NotificationKind.booking,
    ]);
  });
}
