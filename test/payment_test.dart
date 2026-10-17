import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/core/utils/checkout_launcher.dart';
import 'package:soothifyafrica/app/data/models/booked_session.dart';
import 'package:soothifyafrica/app/data/models/checkout.dart';
import 'package:soothifyafrica/app/data/repositories/billing_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_billing_repository.dart';
import 'package:soothifyafrica/app/data/models/session_offering.dart';
import 'package:soothifyafrica/app/data/models/booked_slot.dart';
import 'package:soothifyafrica/app/modules/user/payment/booking_payment_screen.dart';
import 'package:soothifyafrica/app/modules/user/payment/controller/booking_payment_controller.dart';
import 'package:soothifyafrica/app/modules/user/payment/payment_success_screen.dart';

import 'helpers.dart';
import 'package:soothifyafrica/app/modules/user/payment/care_guarantee_screen.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';

/// Regenerate with:
///   flutter test --update-goldens test/payment_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<BookingPaymentController> mount(
    WidgetTester tester,
    SessionOffering offering, {
    Brightness brightness = Brightness.light,
    Widget screen = const BookingPaymentScreen(),
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(BookingPaymentController(offering, MockBillingRepository()));
    await pumpScreen(tester, screen, brightness: brightness);
    return c;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    // The therapist frame spells the cancellation policy out; the two track
    // frames reduce it to a line under the button, and are identical to each
    // other — so one of them stands for both.
    for (final offering in [SessionOffering.therapy, SessionOffering.meditation]) {
      testWidgets('booking payment ${offering.id}, $name', (tester) async {
        await mount(tester, offering, brightness: brightness);

        await expectLater(
          find.byType(BookingPaymentScreen),
          matchesGoldenFile('goldens/payment_${offering.id}_$name.png'),
        );
      });
    }

    testWidgets('payment success, $name', (tester) async {
      await mount(tester, SessionOffering.therapy,
          brightness: brightness, screen: const PaymentSuccessScreen());

      await expectLater(find.byType(PaymentSuccessScreen),
          matchesGoldenFile('goldens/payment_success_$name.png'));
    });
  }

  testWidgets('one card now, and it lists what the session includes',
      (tester) async {
    await mount(tester, SessionOffering.therapy);

    // The redrawn screen dropped the Monthly Plan card beside Single Session.
    expect(find.text('Single Session'), findsOneWidget);
    expect(find.text('Monthly Plan'), findsNothing);
    expect(find.textContaining('25,000'), findsOneWidget);
    expect(find.textContaining('/50-minute session'), findsOneWidget);

    for (final line in SessionCardIncludes.lines) {
      expect(find.text(line), findsOneWidget, reason: line);
    }
  });

  testWidgets('the therapist frame’s prices and policy are its own',
      (tester) async {
    await mount(tester, SessionOffering.therapy);
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.textContaining('Ready for your session with'), findsOneWidget);
    expect(find.text('Cancellation Policy'), findsOneWidget);
    expect(find.text('Proceed to Payment'), findsOneWidget);
    // The full policy replaces the one-line footnote on this frame.
    expect(find.textContaining('Free cancellation or rescheduling'),
        findsNothing);
  });

  testWidgets('a track frame carries the same panel as the therapist one',
      (tester) async {
    // It used to reduce the refund rules to a line under the button. The
    // rules do not depend on which discipline was booked, and the designer
    // settled on the panel for all three on 2026-10-09.
    await mount(tester, SessionOffering.meditation);
    expect(find.text('Cancellation Policy'), findsOneWidget);
    expect(find.textContaining('Free cancellation or rescheduling'),
        findsNothing);
  });

  testWidgets('the receipt’s scrambled line is corrected', (tester) async {
    await mount(tester, SessionOffering.therapy,
        screen: const PaymentSuccessScreen());
    // The frame writes "Your was Payment successful".
    expect(find.text('Your payment was successful'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  group('prices', () {
    test('the two tracks are priced alike, the therapist higher', () {
      expect(SessionOffering.meditation.single,
          SessionOffering.balance.single);
      expect(SessionOffering.meditation.monthly,
          SessionOffering.balance.monthly);
      expect(SessionOffering.therapy.single,
          greaterThan(SessionOffering.meditation.single));
    });


    test('a figure is grouped and carries its currency', () {
      // The frames print a bare "25,000"; the naira sign is this app's, so
      // that a payment screen never shows an amount with no unit.
      expect(BookingPaymentController.money(25000), '₦25,000');
      expect(BookingPaymentController.money(75000), '₦75,000');
      expect(BookingPaymentController.money(1000000), '₦1,000,000');
    });
  });

  testWidgets('the payment screen names the slot the calendar picked',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(BookingPaymentController(
      SessionOffering.therapy,
      MockBillingRepository(),
      booked: BookedSlot(
        offering: SessionOffering.therapy,
        day: DateTime(2026, 10, 14),
        slot: '11:00am',
      ),
    ));

    await pumpScreen(tester, const BookingPaymentScreen());
    await tester.pumpAndSettle();

    // The day is chosen before the price now, so the screen says what is
    // being paid for.
    expect(find.text('Wednesday, 14 October at 11:00am'), findsOneWidget);

    await expectLater(find.byType(BookingPaymentScreen),
        matchesGoldenFile('goldens/payment_with_slot.png'));
  });

  group('confirm booking', () {
    testWidgets('the booking chain goes through it, not straight to the receipt',
        (tester) async {
      useDesignFrame(tester);
      disableMotion(tester);
      await loadAppFonts();
      Get.testMode = true;
      Get.put(BookingPaymentController(
        SessionOffering.meditation,
        MockBillingRepository(),
        booked: BookedSlot(
          offering: SessionOffering.meditation,
          day: DateTime(2026, 10, 14),
          slot: '11:00am',
        ),
      ));

      await tester.pumpWidget(
        Sizer(
          builder: (_, _, _) => GetMaterialApp(
            theme: theme,
            builder: (context, widget) {
              PrimaryColors.syncFrom(context);
              return widget!;
            },
            initialRoute: AppRoutes.bookingPayment,
            getPages: [
              GetPage(
                name: AppRoutes.bookingPayment,
                page: () => const BookingPaymentScreen(),
              ),
              GetPage(
                name: AppRoutes.confirmBooking,
                page: () => const CareGuaranteeScreen(),
              ),
              GetPage(
                name: AppRoutes.paymentSuccess,
                page: () => const Scaffold(body: Text('receipt')),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Proceed to Payment'));
      await tester.pumpAndSettle();

      // The screen was built and never reached — paying used to skip it.
      expect(Get.currentRoute, AppRoutes.confirmBooking);
      expect(find.text('Confirm booking'), findsOneWidget);
      expect(find.text('Pay with card'), findsOneWidget);
      // Priced from the offering that was booked, not the therapy default.
      expect(find.text('₦10,000'), findsNWidgets(2));

      await expectLater(find.byType(CareGuaranteeScreen),
          matchesGoldenFile('goldens/confirm_booking.png'));

      // Paying used to walk straight on to the receipt. It asks the server
      // for a checkout now, and this older entry point reached the screen
      // without booking a time -- so it says so rather than charging for a
      // session that does not exist.
      await tester.tap(find.text('Pay with card'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.confirmBooking);
      // That answer comes as a snackbar; let it go rather than leaving its
      // timer running past the end of the test.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('the receipt waits for the server, not for the browser',
        (tester) async {
      useDesignFrame(tester);
      disableMotion(tester);
      await loadAppFonts();
      Get.testMode = true;

      final opened = <String>[];
      CheckoutLauncher.opener = (url) async {
        opened.add(url);
        return true;
      };
      addTearDown(() => CheckoutLauncher.opener = _realOpener);

      // Not paid on the first ask: the webhook has not landed yet.
      final billing = _StubBilling(const ['pending', 'paid']);
      Get.put(BookingPaymentController(
        SessionOffering.therapy,
        billing,
        session: BookedSession(
          id: '11',
          discipline: 'therapy',
          expertName: 'Jacob Samuel',
          startsAt: DateTime(2026, 10, 14, 11),
          endsAt: DateTime(2026, 10, 14, 12),
          status: 'pending',
          priceNaira: 25000,
        ),
      ));

      await pumpScreen(
        tester,
        const CareGuaranteeScreen(),
        pages: [
          GetPage(
            name: AppRoutes.paymentSuccess,
            page: () => const Scaffold(body: Text('receipt')),
          ),
        ],
      );

      await tester.tap(find.text('Pay with card'));
      await tester.pump();
      // The checkout opens in the browser, outside the app.
      expect(opened.single, 'https://pay.bachs.io/c/1');

      // While it is out there, the button says what is happening and cannot
      // be pressed into starting a second payment.
      await tester.pump();
      expect(find.text('Waiting for payment\u2026'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));   // asked: pending
      await tester.pump(const Duration(seconds: 5));   // asked: paid
      await tester.pumpAndSettle();

      expect(billing.polls, 2, reason: 'it stops asking once it is paid');
      expect(find.text('receipt'), findsOneWidget);
    });
  });
}

/// The opener the app uses, kept so a test can put it back.
final _realOpener = CheckoutLauncher.opener;

/// A billing server that answers a fixed sequence of payment states.
class _StubBilling implements BillingRepository {
  _StubBilling(this._statuses);

  final List<String> _statuses;
  int polls = 0;

  @override
  Future<Checkout> paySession(String sessionId, {String promoCode = ''}) async =>
      const Checkout(
        reference: 'ref_1',
        checkoutUrl: 'https://pay.bachs.io/c/1',
        amountNaira: 25000,
      );

  @override
  Future<String> paymentStatus(String reference) async {
    final answer = _statuses[polls.clamp(0, _statuses.length - 1)];
    polls++;
    return answer;
  }

  @override
  Future<MembershipStatus> membership() async => MembershipStatus.none;

  @override
  Future<Checkout> startMembership({
    required String planKey,
    String cadence = 'annual',
    bool trial = true,
    String promoCode = '',
  }) =>
      throw UnimplementedError();

  @override
  Future<MembershipStatus> cancelMembership() => throw UnimplementedError();

  @override
  Future<Checkout> replaceCard() => throw UnimplementedError();

  @override
  Future<List<BillingInvoice>> invoices() async => const [];

  @override
  Future<Map<String, dynamic>?> checkPromo(String code) async => null;
}