import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:soothifyafrica/app/data/models/plan_tier.dart';
import 'package:soothifyafrica/app/data/repositories/subscription_repository.dart';
import 'package:soothifyafrica/app/modules/user/plans/controller/plans_tab_controller.dart';
import 'package:soothifyafrica/app/modules/user/plans/plans_tab.dart';
import 'package:soothifyafrica/app/widgets/skeleton.dart';

import 'helpers.dart';

/// The Plans screen while it is loading.
///
/// It drew nothing until the tiers arrived, so the page read as a plans
/// page with no plans on it — and on a cold server that is the first
/// thing anybody sees.
class _SlowPlans implements SubscriptionRepository {
  _SlowPlans(this._tiers, {this.delay = const Duration(seconds: 2)});

  final List<PlanTier> _tiers;
  final Duration delay;

  @override
  Future<List<PlanTier>> getTiers(BillingPeriod period) async {
    await Future<void>.delayed(delay);
    return _tiers;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

class _FailingPlans implements SubscriptionRepository {
  @override
  Future<List<PlanTier>> getTiers(BillingPeriod period) async =>
      throw Exception('offline');

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('it shimmers while the tiers are being fetched', (tester) async {
    useDesignFrame(tester);
    // Without the real fonts the text metrics differ and the period
    // toggle overflows by ten pixels, which fails the test for a reason
    // that has nothing to do with it.
    await loadAppFonts();
    Get.put<SubscriptionRepository>(_SlowPlans(const []));
    Get.put(PlansTabController(Get.find<SubscriptionRepository>()));

    await pumpScreen(tester, const PlansTab());

    // Up before the answer lands, in the shape of the real cards.
    expect(find.byType(Skeleton), findsWidgets);
    expect(find.textContaining('could not load'), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('the shimmer goes when the tiers arrive', (tester) async {
    useDesignFrame(tester);
    // Without the real fonts the text metrics differ and the period
    // toggle overflows by ten pixels, which fails the test for a reason
    // that has nothing to do with it.
    await loadAppFonts();
    Get.put<SubscriptionRepository>(
      _SlowPlans(
        const [
          PlanTier(
            id: 'core',
            name: 'Soothify Core',
            description: 'Everything in the library.',
          ),
        ],
        delay: const Duration(milliseconds: 100),
      ),
    );
    Get.put(PlansTabController(Get.find<SubscriptionRepository>()));

    await pumpScreen(tester, const PlansTab());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byType(Skeleton), findsNothing);
    // SoothifyText splits the brand word into its own spans, so the
    // plain finder never matches it.
    expect(findSoothify('Soothify Core'), findsOneWidget);
  });

  testWidgets('a failure says so rather than sitting blank', (tester) async {
    useDesignFrame(tester);
    // Without the real fonts the text metrics differ and the period
    // toggle overflows by ten pixels, which fails the test for a reason
    // that has nothing to do with it.
    await loadAppFonts();
    Get.put<SubscriptionRepository>(_FailingPlans());
    Get.put(PlansTabController(Get.find<SubscriptionRepository>()));

    await pumpScreen(tester, const PlansTab());
    await tester.pumpAndSettle();

    expect(find.byType(Skeleton), findsNothing);
    expect(find.textContaining('could not load'), findsOneWidget);
  });
}
