import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/mood.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/modules/user/mood_recommendation/controller/mood_recommendation_controller.dart';
import 'package:soothifyafrica/app/modules/user/mood_recommendation/mood_recommendation_screen.dart';
import 'package:soothifyafrica/app/modules/user/shell/tabs/widgets/recommended_card.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/mood_recommendation_test.dart
const _covers = [
  'assets/images/content/cover_a.png',
  'assets/images/content/cover_b.png',
  'assets/images/content/cover_c.png',
  'assets/images/content/cover_d.png',
  'assets/images/content/daily_focus.png',
  'assets/images/content/breath_work.png',
  'assets/images/content/mindfulness.png',
];

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<MoodRecommendationController> mount(
    WidgetTester tester,
    MoodLevel level, {
    Brightness brightness = Brightness.light,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<ContentRepository>(MockContentRepository());
    final c = Get.put(
      MoodRecommendationController(Get.find<ContentRepository>(), level),
    );
    await pumpScreen(tester, const MoodRecommendationScreen(),
        brightness: brightness);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    return c;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('mood recommendation, $name', (tester) async {
      await mount(tester, MoodLevel.awful, brightness: brightness);
      await precacheAll(
          tester, find.byType(MoodRecommendationScreen), _covers);

      await expectLater(find.byType(MoodRecommendationScreen),
          matchesGoldenFile('goldens/mood_recommendation_$name.png'));
    });
  }

  testWidgets('three cards, as every one of the ten frames draws',
      (tester) async {
    await mount(tester, MoodLevel.awful);
    expect(find.byType(RecommendedCard), findsNWidgets(3));
    expect(find.text('Mood Checker'), findsOneWidget);
  });

  testWidgets('each mood opens with its own line, not a shared one',
      (tester) async {
    for (final level in [MoodLevel.awful, MoodLevel.awesome]) {
      final c = await mount(tester, level);
      expect(c.intro, level.recommendationIntro);
      expect(find.textContaining(level.recommendationIntro.split('.').first),
          findsOneWidget);
      Get.reset();
    }
  });

  test('every mood has a line of its own', () {
    // Ten frames, ten openings — none reused.
    final intros = {
      for (final l in MoodLevel.values) l: l.recommendationIntro,
    };
    expect(intros.values.toSet(), hasLength(MoodLevel.values.length));
  });
}
