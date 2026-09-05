import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/discussion.dart';
import 'package:soothifyafrica/app/data/repositories/community_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_community_repository.dart';
import 'package:soothifyafrica/app/modules/user/community/thread/controller/thread_controller.dart';
import 'package:soothifyafrica/app/modules/user/community/thread/thread_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/thread_golden_test.dart
const _art = [
  'assets/images/community/avatar_member.png',
];

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  // Pinned: every row prints a relative time, so a real clock would make the
  // golden stale within the minute.
  DateTime now() => DateTime(2024, 7, 15, 9, 41);

  Discussion post() => Discussion(
        id: '1',
        title: 'Depressed and tired',
        body: 'Depression is a topic people don’t talk\nabout enough, I was '
            'battling with \ndepression for a while and I found help here.',
        author: 'Kosin',
        likes: 3,
        comments: 4,
        shares: 3,
        postedAt: now().subtract(const Duration(hours: 1)),
      );

  void boot() {
    Get.lazyPut<CommunityRepository>(() => MockCommunityRepository(now: now));
    Get.lazyPut(() => ThreadController(
          Get.find<CommunityRepository>(),
          post(),
          now: now,
        ));
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('thread, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      boot();

      await pumpScreen(tester, const ThreadScreen(), brightness: brightness);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      await precacheAll(tester, find.byType(ThreadScreen), _art);

      await expectLater(find.byType(ThreadScreen),
          matchesGoldenFile('goldens/thread_$name.png'));
    });
  }

  testWidgets('sending a reply appends it and clears the field',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    SharedPreferences.setMockInitialValues({
      'flutter.communityUsername': 'Kosin',
    });
    await PrefUtils().init();
    boot();

    await pumpScreen(tester, const ThreadScreen());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final controller = Get.find<ThreadController>();
    expect(controller.comments.length, 3);
    expect(controller.canSend.value, isFalse);

    await tester.enterText(find.byType(TextField), 'Thank you for sharing');
    await tester.pumpAndSettle();
    expect(controller.canSend.value, isTrue);

    // runAsync: the mock's latency is a real timer that the fake clock in a
    // widget test does not advance.
    await tester.runAsync(controller.send);
    await tester.pumpAndSettle();

    expect(controller.comments.length, 4);
    expect(controller.comments.last.body, 'Thank you for sharing');
    expect(controller.comments.last.author, 'Kosin');
    // Cleared, so the reply cannot be sent twice by a stray second tap.
    expect(controller.message.text, isEmpty);
  });

  testWidgets('a blank reply is not sent', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    boot();

    await pumpScreen(tester, const ThreadScreen());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final controller = Get.find<ThreadController>();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pumpAndSettle();

    expect(controller.canSend.value, isFalse);
    await tester.runAsync(controller.send);
    expect(controller.comments.length, 3);
  });
}
