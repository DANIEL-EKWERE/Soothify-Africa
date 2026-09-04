import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/data/models/kyc_question.dart';
import 'package:soothifyafrica/app/data/repositories/kyc_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_kyc_repository.dart';
import 'package:soothifyafrica/app/modules/auth/kyc/controller/kyc_controller.dart';
import 'package:soothifyafrica/app/modules/auth/kyc/kyc_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/kyc_golden_test.dart
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(Get.reset);

  /// Every asset any question can show, so no row renders blank.
  Iterable<String> allIcons() => KycQuestion.all
      .expand((q) => q.options)
      .map((o) => o.assetPath)
      .whereType<String>();

  Future<KycController> arrange(
    WidgetTester tester,
    Brightness brightness, {
    int step = 0,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();

    Get.put<KycRepository>(LocalKycRepository());
    final c = Get.put(KycController(Get.find<KycRepository>()));
    c.step.value = step;

    await pumpScreen(tester, const KycScreen(), brightness: brightness);
    await precacheAll(tester, find.byType(KycScreen), allIcons());
    return c;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('kyc concerns empty, $name', (tester) async {
      await arrange(tester, brightness);
      await expectLater(find.byType(KycScreen),
          matchesGoldenFile('goldens/kyc_empty_$name.png'));
    });

    testWidgets('kyc concerns selected, $name', (tester) async {
      final c = await arrange(tester, brightness);
      c.choose(KycQuestion.all.first.options.first);
      await tester.pumpAndSettle();

      await expectLater(find.byType(KycScreen),
          matchesGoldenFile('goldens/kyc_selected_$name.png'));
    });

    testWidgets('kyc goals, $name', (tester) async {
      // Step 4 is the only question whose rows all carry icons.
      await arrange(tester, brightness, step: 3);
      await expectLater(find.byType(KycScreen),
          matchesGoldenFile('goldens/kyc_goals_$name.png'));
    });

    testWidgets('kyc age wheel, $name', (tester) async {
      await arrange(tester, brightness, step: 5);
      await expectLater(find.byType(KycScreen),
          matchesGoldenFile('goldens/kyc_age_$name.png'));
    });
  }
}
