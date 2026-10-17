import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/data/models/bank_destination.dart';
import 'package:soothifyafrica/app/data/models/payout_method.dart';
import 'package:soothifyafrica/app/data/repositories/expert_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_expert_repository.dart';
import 'package:soothifyafrica/app/modules/practitioner/dashboard/controller/expert_dashboard_controller.dart';
import 'package:soothifyafrica/app/modules/practitioner/payouts/controller/payout_controller.dart';
import 'package:soothifyafrica/app/modules/practitioner/payouts/expert_bank_details_screen.dart';
import 'package:soothifyafrica/app/modules/practitioner/payouts/expert_payout_method_screen.dart';
import 'package:soothifyafrica/app/modules/practitioner/payouts/expert_payouts_screen.dart';
import 'package:soothifyafrica/app/modules/practitioner/payouts/expert_withdraw_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/payouts_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  DateTime now() => DateTime(2026, 9, 26, 9, 41);

  Future<PayoutController> mount(
    WidgetTester tester,
    Widget screen, {
    Brightness brightness = Brightness.light,
    List<GetPage<dynamic>>? pages,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<ExpertRepository>(MockExpertRepository(now: now));
    final dashboard = Get.put(
      ExpertDashboardController(Get.find<ExpertRepository>(), now: now),
    );
    final c = Get.put(PayoutController(dashboard));
    await pumpScreen(tester, screen, brightness: brightness, pages: pages);
    // Let the repository's latency pass so the balance lands.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    return c;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('withdraw, $name', (tester) async {
      await mount(tester, const ExpertWithdrawScreen(), brightness: brightness);

      await expectLater(find.byType(ExpertWithdrawScreen),
          matchesGoldenFile('goldens/expert_withdraw_$name.png'));
    });

    testWidgets('payout method, $name', (tester) async {
      await mount(tester, const ExpertPayoutMethodScreen(),
          brightness: brightness);

      await expectLater(find.byType(ExpertPayoutMethodScreen),
          matchesGoldenFile('goldens/expert_payout_method_$name.png'));
    });

    testWidgets('payout method chooser, $name', (tester) async {
      final c = await mount(tester, const ExpertPayoutMethodScreen(),
          brightness: brightness);
      // The first withdrawal: nothing is on file, so the chooser shows.
      c.destinations.clear();
      await tester.pumpAndSettle();

      await expectLater(find.byType(ExpertPayoutMethodScreen),
          matchesGoldenFile('goldens/expert_payout_chooser_$name.png'));
    });

    testWidgets('bank details, $name', (tester) async {
      await mount(tester, const ExpertBankDetailsScreen(),
          brightness: brightness);

      await expectLater(find.byType(ExpertBankDetailsScreen),
          matchesGoldenFile('goldens/expert_bank_details_$name.png'));
    });

    testWidgets('recent payouts, $name', (tester) async {
      await mount(tester, const ExpertPayoutsScreen(), brightness: brightness);

      await expectLater(find.byType(ExpertPayoutsScreen),
          matchesGoldenFile('goldens/expert_payouts_$name.png'));
    });
  }

  testWidgets('the amount opens on the whole balance', (tester) async {
    final c = await mount(tester, const ExpertWithdrawScreen());
    expect(c.available, 1240);
    expect(c.amount.text, '1240');
    expect(c.requested, 1240);
    expect(c.canProceed, isTrue);
  });

  testWidgets('more than the balance cannot go through', (tester) async {
    final c = await mount(tester, const ExpertWithdrawScreen());
    // Nothing in the frames says what happens here, but a payout screen must
    // not let it through.
    c.amount.text = '9999';
    expect(c.canProceed, isFalse);

    c.amount.text = '0';
    expect(c.canProceed, isFalse);

    c.amount.text = '';
    expect(c.requested, 0);
    expect(c.canProceed, isFalse);

    c.amount.text = '500';
    expect(c.canProceed, isTrue);
  });

  testWidgets('the destination carries across to the method screen',
      (tester) async {
    final c = await mount(tester, const ExpertWithdrawScreen());
    expect(c.method.value, PayoutMethod.bankTransfer,
        reason: 'the frame outlines Bank Transfer in blue');

    c.choose(PayoutMethod.mobileMoney);
    await tester.pumpAndSettle();
    expect(c.method.value, PayoutMethod.mobileMoney);
  });

  testWidgets('the tiles are the accounts on file, not the three methods',
      (tester) async {
    final c = await mount(tester, const ExpertWithdrawScreen());
    expect(c.destinations, hasLength(1));
    expect(find.text('Access Bank'), findsOneWidget);
    expect(find.text('Bank Transfer'), findsOneWidget);

    c.destinations.addAll(const [
      BankDestination(
        bank: 'Kuda Bank',
        accountNumber: '2200110011',
        accountName: 'Baraqhat Ibrahim',
      ),
      BankDestination(
        bank: 'Opay',
        accountNumber: '9900110022',
        accountName: 'Baraqhat Ibrahim',
      ),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('Kuda Bank'), findsOneWidget);
    expect(find.text('Bank Transfer'), findsNWidgets(3));

    expect(c.chosenDestination.value, 0);
    c.chooseDestination(2);
    await tester.pumpAndSettle();
    expect(c.chosenDestination.value, 2);
  });

  testWidgets('with an account on file the method screen shows it',
      (tester) async {
    final c = await mount(tester, const ExpertPayoutMethodScreen());
    expect(c.hasDestination, isTrue);
    expect(find.text('Payout Method'), findsOneWidget);
    expect(find.text('Access Bank'), findsOneWidget);
    expect(find.text('0234 5678 890'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Back to Earnings'), findsOneWidget);
    // The frame's account number has eleven digits; the last four win.
    expect(c.savedDestination, 'Bank ****8890');
  });

  testWidgets('with nothing on file it offers Bank Transfer', (tester) async {
    final c = await mount(tester, const ExpertPayoutMethodScreen());
    // The first withdrawal: nothing has been added yet.
    c.destinations.clear();
    await tester.pumpAndSettle();
    expect(find.text('Payout method'), findsOneWidget);
    // The frame draws one card, not three: the other two methods have no
    // form behind them.
    expect(find.text(PayoutMethod.bankTransfer.label), findsOneWidget);
    expect(find.text(PayoutMethod.paystackCard.label), findsNothing);
    expect(find.text(PayoutMethod.mobileMoney.label), findsNothing);
    expect(find.text('paystack'), findsOneWidget);
    expect(find.text('Proceed'), findsOneWidget);
  });

  testWidgets('the form adds an account, and editing one replaces it',
      (tester) async {
    final c = await mount(
      tester,
      const ExpertPayoutMethodScreen(),
      // Saving leaves for the confirmation, and the pencil for the form.
      pages: [
        GetPage(
          name: AppRoutes.expertPayoutOutcome,
          page: () => const SizedBox.shrink(),
        ),
        GetPage(
          name: AppRoutes.expertBankDetails,
          page: () => const SizedBox.shrink(),
        ),
      ],
    );
    c.destinations.clear();
    // The picker's banks come from the provider now, with the codes its
    // account lookup needs -- a bank with no code cannot be saved.
    await settleLoads(tester);
    expect(c.banks, contains('Kuda Bank'));

    c.chooseBank('Kuda Bank');
    c.accountNumber.text = '2200110011';
    expect(c.canSaveBank, isTrue);
    // Not awaited: the save's own delay only elapses while the tester
    // pumps, so awaiting it here would deadlock the test.
    unawaited(c.saveBankDetails());
    await settleLoads(tester);

    expect(c.destinations, hasLength(1));
    expect(c.destinations.first.bank, 'Kuda Bank');
    expect(c.destinations.first.masked, 'Bank ****0011');

    // The pencil fills in the bank and the name, but asks for the number
    // again: only its last four digits are kept here -- the rest went to
    // the provider -- and saving four digits is a payout going nowhere.
    c.editDestination(0);
    expect(c.bank.value, 'Kuda Bank');
    expect(c.accountNumber.text, isEmpty);
    expect(c.canSaveBank, isFalse);

    // And "+ Add New Payout Method" starts from an empty form.
    c.addDestination();
    expect(c.bank.value, isEmpty);
    expect(c.accountNumber.text, isEmpty);
    expect(c.canSaveBank, isFalse);
  });

  testWidgets('the history lists every payout in naira', (tester) async {
    final c = await mount(tester, const ExpertPayoutsScreen());
    expect(c.payouts, hasLength(4));
    expect(find.text('Recent payouts'), findsOneWidget);
    expect(find.text('Weekly payout'), findsNWidgets(4));
    // The frame prints "$1,105" here and "₦1240" on the screen linking to it.
    expect(find.text('₦1,105'), findsNWidgets(4));
    expect(find.textContaining(r'$'), findsNothing);
  });

  group('the copy the frames got wrong', () {
    test('Naira is spelled correctly, and the bracket is closed', () {
      // The frame writes "(Naria)" and leaves "(select network" open.
      expect(PayoutMethod.paystackCard.blurb, contains('(Naira)'));
      expect(PayoutMethod.paystackCard.blurb, isNot(contains('Naria')));
      expect(PayoutMethod.mobileMoney.blurb, endsWith('(select network)'));
    });

    test('the masked row takes the last four digits of the account', () {
      const d = BankDestination(
        bank: 'Access Bank',
        accountNumber: '0234 5678 890',
        accountName: 'Baraqhat Ibrahim',
      );
      expect(d.masked, 'Bank ****8890');
    });

    test('only Bank Transfer names an account', () {
      expect(PayoutMethod.bankTransfer.account, 'Access Bank');
      expect(PayoutMethod.paystackCard.account, isNull);
      expect(PayoutMethod.mobileMoney.account, isNull);
    });
  });
}
