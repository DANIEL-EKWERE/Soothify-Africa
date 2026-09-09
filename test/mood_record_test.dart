import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/repositories/local_mood_repository.dart';
import 'package:soothifyafrica/app/modules/user/mood_record/controller/mood_record_controller.dart';

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  // A Wednesday, so the week sits inside one month and "today" is mid-strip.
  final wednesday = DateTime(2026, 9, 2, 9, 41);
  DateTime now() => wednesday;

  group('LocalMoodRepository.between', () {
    test('includes an entry recorded on a boundary day', () async {
      final repo = LocalMoodRepository(now: now);
      await repo.record(0.85);

      final found = await repo.between(wednesday, wednesday);
      expect(found, hasLength(1));
      expect(found.single.score, closeTo(0.85, 1e-9));
    });

    test('excludes days outside the range', () async {
      final repo = LocalMoodRepository(now: now);
      await repo.record(0.10);

      final lastWeek = wednesday.subtract(const Duration(days: 7));
      expect(await repo.between(lastWeek, lastWeek), isEmpty);
    });
  });

  group('MoodRecordController', () {
    test('the week runs Sunday to Saturday', () {
      final c = MoodRecordController(LocalMoodRepository(now: now), now: now);
      expect(c.labels, ['SUN', 'MON', 'TUE', 'WED', 'THUR', 'FRI', 'SAT']);
    });

    test('today lands on the right column', () {
      final c = MoodRecordController(LocalMoodRepository(now: now), now: now);
      // 2 September 2026 is a Wednesday: Sunday is 0, so Wednesday is 3.
      expect(c.todayIndex, 3);
    });

    test('marks only the days that have a check-in', () async {
      final repo = LocalMoodRepository(now: now);
      await repo.record(0.75);

      final c = MoodRecordController(repo, now: now)..onInit();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(c.completed[3], isTrue, reason: 'today was logged');
      expect(c.completed.where((d) => d).length, 1);
    });

    test('drops the name from the headline when there is none', () {
      final c = MoodRecordController(LocalMoodRepository(now: now), now: now);
      expect(c.headline, 'Nice job today.');

      c.name.value = 'Rita';
      expect(c.headline, contains('Rita'));
    });
  });
}
