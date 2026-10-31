import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/data/models/booked_session.dart';
import 'package:soothifyafrica/app/data/models/session_mode.dart';
import 'package:soothifyafrica/app/data/models/session_offering.dart';
import 'package:soothifyafrica/app/data/repositories/mock_billing_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_booking_repository.dart';
import 'package:soothifyafrica/app/modules/user/booking_calendar/booking_calendar_screen.dart';
import 'package:soothifyafrica/app/modules/user/booking_calendar/booking_confirmed_screen.dart';
import 'package:soothifyafrica/app/modules/user/booking_calendar/controller/booking_calendar_controller.dart';
import 'package:soothifyafrica/app/modules/user/payment/controller/booking_payment_controller.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/booking_calendar_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('booking calendar, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(BookingCalendarController(
      MockBookingRepository(),
      now: () => DateTime(2026, 10, 5),
    ));

      await pumpScreen(tester, const BookingCalendarScreen(),
          brightness: brightness);
    await settleLoads(tester);
      await expectLater(find.byType(BookingCalendarScreen),
          matchesGoldenFile('goldens/booking_calendar_$name.png'));
    });
  }

  testWidgets('the calendar leads to payment, carrying the chosen time',
      (tester) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    Get.testMode = true;
    final c = Get.put(BookingCalendarController(
      MockBookingRepository(),
      now: () => DateTime(2026, 10, 5),
    ));

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          builder: (context, widget) {
            PrimaryColors.syncFrom(context);
            return widget!;
          },
          initialRoute: AppRoutes.bookingCalendar,
          getPages: [
            GetPage(
              name: AppRoutes.bookingCalendar,
              page: () => const BookingCalendarScreen(),
            ),
            GetPage(
              name: AppRoutes.bookingPayment,
              page: () => const Scaffold(body: Text('payment')),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await settleLoads(tester);

    c.pickDay(DateTime(2026, 10, 14));
    await tester.tap(find.text('11:00am'));
    await tester.pumpAndSettle();
    // The communication picker sits between the hour and payment now, and
    // a test has no navigator to show it on.
    c.confirm(mode: SessionMode.video);
    // Booking holds the hour on the server before the screen moves on.
    await settleLoads(tester);

    // The day is chosen before the price now, and travels with it -- as the
    // session the server is holding, rather than only a time: paying has to
    // know which booking it is paying for.
    expect(Get.currentRoute, AppRoutes.bookingPayment);
    final session = Get.arguments as BookedSession;
    expect(session.startsAt, DateTime(2026, 10, 14, 11));
    expect(session.discipline, 'therapy');
    expect(session.awaitingPayment, isTrue,
        reason: 'the hour is held, not confirmed, until it is paid for');
  });

  testWidgets('the receipt leads to the confirmation, not back to a calendar',
      (tester) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    Get.testMode = true;
    Get.put(BookingPaymentController(
      SessionOffering.therapy,
      MockBillingRepository(),
    ));

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          builder: (context, widget) {
            PrimaryColors.syncFrom(context);
            return widget!;
          },
          initialRoute: AppRoutes.paymentSuccess,
          getPages: [
            GetPage(
              name: AppRoutes.paymentSuccess,
              page: () => const Scaffold(body: Text('receipt')),
            ),
            GetPage(
              name: AppRoutes.bookingConfirmed,
              page: () => const Scaffold(body: Text('confirmed')),
            ),
            GetPage(
              name: AppRoutes.bookingCalendar,
              page: () => const Scaffold(body: Text('calendar')),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    Get.find<BookingPaymentController>().done();
    await tester.pumpAndSettle();

    // The day was picked before paying, so there is nothing left to choose:
    // the receipt ends on the confirmation.
    expect(Get.currentRoute, AppRoutes.bookingConfirmed);
    expect(find.text('calendar'), findsNothing);
  });

  testWidgets('a day and a time are both needed before confirming',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(BookingCalendarController(
      MockBookingRepository(),
      now: () => DateTime(2026, 10, 5),
    ));

    await pumpScreen(tester, const BookingCalendarScreen());
    await settleLoads(tester);
    expect(c.canConfirm, isFalse);

    c.pickDay(DateTime(2026, 10, 14));
    await tester.pumpAndSettle();
    expect(c.canConfirm, isFalse, reason: 'a day alone is not a booking');

    await tester.tap(find.text('11:00am'));
    await tester.pumpAndSettle();
    expect(c.canConfirm, isTrue);
    expect(c.summary, 'Wednesday, 14 October at 11:00am');
  });

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('booking confirmed, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.testMode = true;

      await pumpScreen(tester, const BookingConfirmedScreen(),
          brightness: brightness);
      await precacheAll(tester, find.byType(BookingConfirmedScreen),
          const ['assets/images/schedule/booked.png']);
      await expectLater(find.byType(BookingConfirmedScreen),
          matchesGoldenFile('goldens/booking_confirmed_$name.png'));
    });
  }

  testWidgets('the confirmation counts itself down and leaves',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.testMode = true;

    await pumpScreen(tester, const BookingConfirmedScreen());
    expect(find.textContaining('scheduled successfully'), findsOneWidget);
    // The frame carries no button, so it says how long it is staying.
    expect(find.text('Redirecting you back to home in 3 sec'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Redirecting you back to home in 2 sec'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  test('the month steps either way', () {
    Get.testMode = true;
    final c = Get.put(BookingCalendarController(
      MockBookingRepository(),
      now: () => DateTime(2026, 10, 5),
    ));
    expect(c.monthLabel, 'October 2026');
    c.nextMonth();
    expect(c.monthLabel, 'November 2026');
    c.previousMonth();
    c.previousMonth();
    expect(c.monthLabel, 'September 2026');
    expect(c.offering, SessionOffering.therapy);
  });

  testWidgets('a chosen time is outlined in blue, not filled', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(BookingCalendarController(
      MockBookingRepository(),
      now: () => DateTime(2026, 10, 5),
    ));

    await pumpScreen(tester, const BookingCalendarScreen());
    await settleLoads(tester);

    Border borderOf(String slot) {
      final box = tester.widget<Container>(
        find
            .ancestor(of: find.text(slot), matching: find.byType(Container))
            .first,
      );
      return (box.decoration! as BoxDecoration).border! as Border;
    }
    Color fillOf(String slot) {
      final box = tester.widget<Container>(
        find
            .ancestor(of: find.text(slot), matching: find.byType(Container))
            .first,
      );
      return (box.decoration! as BoxDecoration).color!;
    }

    const slot = '11:00am';
    expect(borderOf(slot).top.color, appTheme.cardHairline);

    await tester.tap(find.text(slot));
    await tester.pumpAndSettle();

    expect(c.slot.value, slot);
    expect(borderOf(slot).top.color, appTheme.soothifyBlue);
    // Outlined, not filled — the solid blue belongs to Confirm booking.
    expect(fillOf(slot), appTheme.surface);
    // And only the one that was tapped.
    expect(borderOf('9:00am').top.color, appTheme.cardHairline);
  });
}