import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/data/models/session_offering.dart';
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
      Get.put(BookingCalendarController(now: () => DateTime(2026, 10, 5)));

      await pumpScreen(tester, const BookingCalendarScreen(),
          brightness: brightness);
      await expectLater(find.byType(BookingCalendarScreen),
          matchesGoldenFile('goldens/booking_calendar_$name.png'));
    });
  }

  testWidgets('the receipt leads to the calendar, not back to matching',
      (tester) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    Get.testMode = true;
    Get.put(BookingPaymentController(SessionOffering.therapy));

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
              name: AppRoutes.bookingCalendar,
              page: () => const Scaffold(body: Text('calendar')),
            ),
            GetPage(
              name: AppRoutes.booking,
              page: () => const Scaffold(body: Text('matching')),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    Get.find<BookingPaymentController>().done();
    await tester.pumpAndSettle();

    // It used to land on AppRoutes.booking, which restarts at the matching
    // interstitial — so paying put the user back on "Awesome! You matched
    // with" and no booking was ever made.
    expect(Get.currentRoute, AppRoutes.bookingCalendar);
    expect(find.text('matching'), findsNothing);
  });

  testWidgets('a day and a time are both needed before confirming',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(BookingCalendarController(now: () => DateTime(2026, 10, 5)));

    await pumpScreen(tester, const BookingCalendarScreen());
    expect(c.canConfirm, isFalse);

    c.pickDay(DateTime(2026, 10, 14));
    await tester.pumpAndSettle();
    expect(c.canConfirm, isFalse, reason: 'a day alone is not a booking');

    await tester.tap(find.text('11:00am'));
    await tester.pumpAndSettle();
    expect(c.canConfirm, isTrue);
    expect(c.summary, 'Wednesday, 14 October at 11:00am');
  });

  testWidgets('the confirmation names the slot that was picked',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.testMode = true;

    await pumpScreen(tester, const BookingConfirmedScreen());
    expect(find.text('Your session is booked'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  test('the month steps either way', () {
    Get.testMode = true;
    final c = Get.put(BookingCalendarController(now: () => DateTime(2026, 10, 5)));
    expect(c.monthLabel, 'October 2026');
    c.nextMonth();
    expect(c.monthLabel, 'November 2026');
    c.previousMonth();
    c.previousMonth();
    expect(c.monthLabel, 'September 2026');
    expect(c.offering, SessionOffering.therapy);
  });
}
