import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';

import 'package:soothifyafrica/app/data/repositories/local_mood_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mood_repository.dart';
import 'package:soothifyafrica/app/modules/user/mood_record/controller/mood_record_controller.dart';
import 'package:soothifyafrica/app/modules/user/mood_record/mood_record_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/mood_record_golden_test.dart
void main() {
  // Fixed, not DateTime.now(): the screen highlights "today" on the week
  // strip and in its headline, so a golden built from the real clock goes
  // stale — and fails — the moment the calendar moves past the day it was
  // captured on. A Wednesday mid-week keeps the strip's Sun-Sat span inside
  // one month, which also matches the design's own reference date.
  final fixedNow = DateTime(2026, 9, 2, 9, 41);
  DateTime now() => fixedNow;

  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('mood record, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();

      final repo = LocalMoodRepository(now: now);
      // A logged day so the strip, the card and the headline all show their
      // populated state rather than an empty week.
      await repo.record(0.75);

      Get.put<MoodRepository>(repo);
      Get.put(MoodRecordController(repo, now: now)..name.value = 'Rita');

      await pumpScreen(tester, const MoodRecordScreen(),
          brightness: brightness);
      await tester.pumpAndSettle();

      await expectLater(find.byType(MoodRecordScreen),
          matchesGoldenFile('goldens/mood_record_$name.png'));
    });
  }
}
