import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/payout_method.dart';
import 'package:soothifyafrica/app/data/repositories/expert_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_expert_repository.dart';
import 'package:soothifyafrica/app/modules/practitioner/dashboard/controller/expert_dashboard_controller.dart';
import 'package:soothifyafrica/app/modules/practitioner/payouts/controller/payout_controller.dart';
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
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<ExpertRepository>(MockExpertRepository(now: now));
    final dashboard = Get.put(
      ExpertDashboardController(Get.find<ExpertRepository>(), now: now),
    );
    final c = Get.put(PayoutController(dashboard));
    await pumpScreen(tester, screen, brightness: brightness);
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

  testWidgets('the method screen lists all three, with the frame’s copy',
      (tester) async {
    await mount(tester, const ExpertPayoutMethodScreen());
    expect(find.text('Payout method'), findsOneWidget);
    for (final method in PayoutMethod.values) {
      expect(find.text(method.label), findsOneWidget);
    }
    expect(find.text('paystack'), findsOneWidget);
    expect(find.text('Proceed'), findsOneWidget);
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

    test('only Bank Transfer names an account', () {
      expect(PayoutMethod.bankTransfer.account, 'Access Bank');
      expect(PayoutMethod.paystackCard.account, isNull);
      expect(PayoutMethod.mobileMoney.account, isNull);
    });
  });
}
