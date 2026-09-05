import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/community_topic.dart';
import 'package:soothifyafrica/app/modules/user/community/community_tab.dart';
import 'package:soothifyafrica/app/modules/user/community/controller/community_tab_controller.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/community_golden_test.dart
const _emoji = [
  'assets/images/moods/happy.png',
  'assets/images/moods/sad.png',
  'assets/images/moods/depress.png',
  'assets/images/moods/anxious.png',
  'assets/images/moods/fearful.png',
  'assets/images/community/welcome.png',
  'assets/images/community/avatar.png',
];

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
    testWidgets('community topics, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.lazyPut(() => CommunityTabController());
      // A returning member lands on the topic grid; the welcome and username
      // steps have goldens of their own below.
      SharedPreferences.setMockInitialValues({
        'flutter.communityWelcomeSeen': true,
        'flutter.communityUsername': 'Chidera Dera',
      });
      await PrefUtils().init();
      Get.find<CommunityTabController>().restore();

      await pumpScreen(tester, const CommunityTab(), brightness: brightness);
      await precacheAll(tester, find.byType(CommunityTab), _emoji);

      await expectLater(find.byType(CommunityTab),
          matchesGoldenFile('goldens/community_$name.png'));
    });
  }

  testWidgets('topics toggle and Proceed follows the selection',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.lazyPut(() => CommunityTabController());
    SharedPreferences.setMockInitialValues({
      'flutter.communityWelcomeSeen': true,
      'flutter.communityUsername': 'Chidera Dera',
    });
    await PrefUtils().init();
    final controller = Get.find<CommunityTabController>()..restore();

    await pumpScreen(tester, const CommunityTab());

    // The frame ships Depression outlined.
    expect(controller.isSelected(CommunityTopic.depression), isTrue);
    expect(controller.canProceed, isTrue);

    await tester.tap(find.text('Happy'));
    await tester.pumpAndSettle();
    expect(controller.isSelected(CommunityTopic.happy), isTrue);

    // Clearing every topic must disable Proceed rather than send an empty set.
    controller.selected.clear();
    await tester.pumpAndSettle();
    expect(controller.canProceed, isFalse);
  });

  testWidgets('a first visit walks welcome -> username -> topics',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    Get.lazyPut(() => CommunityTabController());

    await pumpScreen(tester, const CommunityTab());
    final controller = Get.find<CommunityTabController>();

    expect(controller.stage.value, CommunityStage.welcome);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(controller.stage.value, CommunityStage.username);

    // Too short to commit: the forum handle is what other members see.
    controller.usernameDraft.value = 'ab';
    expect(controller.canCreateUsername, isFalse);

    await tester.enterText(find.byType(TextField), 'Kosin');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Username'));
    await tester.pumpAndSettle();

    expect(controller.stage.value, CommunityStage.topics);
    expect(controller.username.value, 'Kosin');
    // Persisted, so the step is not repeated on the next launch.
    expect(PrefUtils().communityUsername(), 'Kosin');
  });

  testWidgets('a returning member skips straight to topics', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    SharedPreferences.setMockInitialValues({
      'flutter.communityWelcomeSeen': true,
      'flutter.communityUsername': 'Kosin',
    });
    await PrefUtils().init();
    Get.lazyPut(() => CommunityTabController());

    await pumpScreen(tester, const CommunityTab());

    expect(Get.find<CommunityTabController>().stage.value,
        CommunityStage.topics);
  });

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('community welcome, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      await PrefUtils().init();
      Get.lazyPut(() => CommunityTabController());

      await pumpScreen(tester, const CommunityTab(), brightness: brightness);
      await precacheAll(tester, find.byType(CommunityTab), _emoji);

      await expectLater(find.byType(CommunityTab),
          matchesGoldenFile('goldens/community_welcome_$name.png'));
    });
  }
}
