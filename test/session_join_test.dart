import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/data/models/session_invite.dart';
import 'package:soothifyafrica/app/data/models/session_offering.dart';
import 'package:soothifyafrica/app/data/repositories/mock_notification_repository.dart';
import 'package:soothifyafrica/app/modules/user/booking/controller/booking_controller.dart';
import 'package:soothifyafrica/app/modules/user/notifications/controller/notifications_controller.dart';
import 'package:soothifyafrica/app/modules/user/notifications/notifications_screen.dart';
import 'package:soothifyafrica/app/modules/user/session/client_joining_screen.dart';
import 'package:soothifyafrica/app/modules/user/session/controller/client_joining_controller.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';

import 'helpers.dart';

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  testWidgets('a session under the Sessions chip opens the waiting room',
      (tester) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    Get.testMode = true;
    Get.put(NotificationsController(
      MockNotificationRepository(now: () => DateTime(2026, 9, 28, 14)),
      now: () => DateTime(2026, 9, 28, 14),
    ));

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          builder: (context, widget) {
            PrimaryColors.syncFrom(context);
            return widget!;
          },
          initialRoute: AppRoutes.notifications,
          getPages: [
            GetPage(
              name: AppRoutes.notifications,
              page: () => const NotificationsScreen(),
            ),
            GetPage(
              name: AppRoutes.clientJoining,
              page: () => const Scaffold(body: Text('joining')),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    // The mock feed answers after 400ms, and `pumpAndSettle` alone will not
    // wait it out — with no animation running it pumps once and stops.
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Sessions'));
    await tester.pumpAndSettle();

    // The booking rows are what the chip leaves on screen. The line is a
    // `Text.rich` — the discipline is bolded inside it — so the finder has to
    // be told to look through to the spans.
    await tester.tap(
      find
          .textContaining('session on 28 Sep 2026', findRichText: true)
          .first,
    );
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.clientJoining);
    expect(find.text('joining'), findsOneWidget);
  });

  testWidgets('the breathe reminder opens the breathing screen',
      (tester) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    Get.testMode = true;
    Get.put(NotificationsController(
      MockNotificationRepository(now: () => DateTime(2026, 9, 28, 14)),
      now: () => DateTime(2026, 9, 28, 14),
    ));

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          builder: (context, widget) {
            PrimaryColors.syncFrom(context);
            return widget!;
          },
          initialRoute: AppRoutes.notifications,
          getPages: [
            GetPage(
              name: AppRoutes.notifications,
              page: () => const NotificationsScreen(),
            ),
            GetPage(
              name: AppRoutes.breathe,
              page: () => const Scaffold(body: Text('breathe')),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));

    // It belongs to Sessions: it is the push that follows booking one.
    await tester.tap(find.text('Sessions'));
    await tester.pumpAndSettle();
    expect(find.textContaining('60 seconds to breathe'), findsOneWidget);

    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.breathe);
  });

  testWidgets('the waiting room goes through to the call', (tester) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    Get.testMode = true;
    Get.put(ClientJoiningController(
      connecting: const Duration(milliseconds: 50),
    ));

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          builder: (context, widget) {
            PrimaryColors.syncFrom(context);
            return widget!;
          },
          initialRoute: AppRoutes.clientJoining,
          getPages: [
            GetPage(
              name: AppRoutes.clientJoining,
              page: () => const ClientJoiningScreen(),
            ),
            GetPage(
              name: AppRoutes.booking,
              page: () => const Scaffold(body: Text('booking')),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.booking);
    // offNamed: the waiting room is gone, so Cancel in the call cannot land
    // back on it.
    expect(find.byType(ClientJoiningScreen), findsNothing);
  });

  test('the booking route can be entered at the call, not just at matching',
      () {
    Get.testMode = true;
    final fresh = BookingController(matchDuration: Duration.zero)..onInit();
    expect(fresh.stage.value, BookingStage.matching);

    final joined = BookingController(
      matchDuration: Duration.zero,
      offering: SessionOffering.therapy,
      startAt: BookingStage.call,
    )..onInit();
    // And it must not walk itself back through matching.
    expect(joined.stage.value, BookingStage.call);
  });

  test('the invite carries what the waiting room prints', () {
    const invite = SessionInvite(
      expertName: 'Baraqhat',
      service: '1-on-1 Yoga',
      time: '5:00pm',
      date: 'Sep 28 2026',
    );
    expect(invite.offering, SessionOffering.therapy);
    expect(invite.service, '1-on-1 Yoga');
  });
}
