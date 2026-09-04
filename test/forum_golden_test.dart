import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/repositories/community_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_community_repository.dart';
import 'package:soothifyafrica/app/modules/user/community/compose/compose_screen.dart';
import 'package:soothifyafrica/app/modules/user/community/compose/controller/compose_controller.dart';
import 'package:soothifyafrica/app/modules/user/community/forum/controller/forum_controller.dart';
import 'package:soothifyafrica/app/modules/user/community/forum/forum_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/forum_golden_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  // Pinned: the cards print "1 hour ago", which a real clock would keep stable
  // only by luck — the seeds are offsets from this instant.
  DateTime now() => DateTime(2024, 7, 15, 9, 41);

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('forum, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.lazyPut<CommunityRepository>(
        () => MockCommunityRepository(now: now),
      );
      Get.lazyPut(
        () => ForumController(Get.find<CommunityRepository>(), now: now),
      );

      await pumpScreen(tester, const ForumScreen(), brightness: brightness);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      await expectLater(find.byType(ForumScreen),
          matchesGoldenFile('goldens/forum_$name.png'));
    });
  }

  testWidgets('composer posts and hands the thread back', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    SharedPreferences.setMockInitialValues({
      'flutter.communityUsername': 'Kosin',
    });
    await PrefUtils().init();
    final repository = MockCommunityRepository(now: now);
    Get.lazyPut<CommunityRepository>(() => repository);
    Get.lazyPut(() => ComposeController(Get.find<CommunityRepository>()));

    await pumpScreen(tester, const ComposeScreen());
    final controller = Get.find<ComposeController>();

    // Nothing to post yet.
    expect(controller.canPost.value, isFalse);

    await tester.enterText(find.byType(TextField), 'Feeling better today');
    await tester.pumpAndSettle();
    expect(controller.canPost.value, isTrue);

    // runAsync: the mock's latency is a real timer, and awaiting it straight
    // from the test body never advances the fake clock — the run hangs.
    await tester.runAsync(controller.post);
    await tester.pumpAndSettle();

    final threads =
        await tester.runAsync(repository.getDiscussions) ?? const [];
    // Newest first, attributed to the stored handle rather than the account.
    expect(threads.first.title, 'Feeling better today');
    expect(threads.first.author, 'Kosin');
  });

  testWidgets('an empty body cannot be posted', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    final repository = MockCommunityRepository(now: now);
    Get.lazyPut<CommunityRepository>(() => repository);
    Get.lazyPut(() => ComposeController(Get.find<CommunityRepository>()));

    await pumpScreen(tester, const ComposeScreen());
    final controller = Get.find<ComposeController>();

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pumpAndSettle();

    expect(controller.canPost.value, isFalse);
    await tester.runAsync(controller.post);
    final threads =
        await tester.runAsync(repository.getDiscussions) ?? const [];
    expect(threads.length, 4);
  });
}
