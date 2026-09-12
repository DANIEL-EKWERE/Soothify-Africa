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
/// Looked up by id rather than hard-coded: the order has moved once already
/// (gender to the front) and a bare index silently pointed these goldens at
/// the wrong screen.
int _stepOf(String id) => KycQuestion.all.indexWhere((q) => q.id == id);
final int _concerns = _stepOf('concerns');
final int _goals = _stepOf('goals');
final int _age = _stepOf('age');

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(Get.reset);

  /// Every asset any question can show, so nothing renders blank — the row
  /// icons and the concerns carousel's illustrations.
  Iterable<String> allIcons() => KycQuestion.all
      .expand((q) => q.options)
      .expand((o) => [o.assetPath, o.illustration, o.illustrationMale])
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
    testWidgets('kyc gender, $name', (tester) async {
      // The opening question, since the concerns carousel needs its answer.
      await arrange(tester, brightness);
      await expectLater(find.byType(KycScreen),
          matchesGoldenFile('goldens/kyc_gender_$name.png'));
    });

    testWidgets('kyc concerns empty, $name', (tester) async {
      await arrange(tester, brightness, step: _concerns);
      await expectLater(find.byType(KycScreen),
          matchesGoldenFile('goldens/kyc_empty_$name.png'));
    });

    testWidgets('kyc concerns, male figure, $name', (tester) async {
      final c = await arrange(tester, brightness, step: _concerns);
      // Answered a step earlier; the carousel reads it to pick the set.
      c.answers['gender'] = {'male'};
      c.answers.refresh();
      await tester.pumpAndSettle();

      await expectLater(find.byType(KycScreen),
          matchesGoldenFile('goldens/kyc_concerns_male_$name.png'));
    });

    testWidgets('kyc concerns selected, $name', (tester) async {
      final c = await arrange(tester, brightness, step: _concerns);
      c.choose(KycQuestion.all[_concerns].options.first);
      await tester.pumpAndSettle();

      await expectLater(find.byType(KycScreen),
          matchesGoldenFile('goldens/kyc_selected_$name.png'));
    });

    testWidgets('kyc goals, $name', (tester) async {
      // The only question whose rows all carry icons.
      await arrange(tester, brightness, step: _goals);
      await expectLater(find.byType(KycScreen),
          matchesGoldenFile('goldens/kyc_goals_$name.png'));
    });

    testWidgets('kyc age wheel, $name', (tester) async {
      await arrange(tester, brightness, step: _age);
      await expectLater(find.byType(KycScreen),
          matchesGoldenFile('goldens/kyc_age_$name.png'));
    });
  }
}
