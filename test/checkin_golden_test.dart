import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/checkin_kind.dart';
import 'package:soothifyafrica/app/data/models/mood.dart';
import 'package:soothifyafrica/app/data/repositories/kyc_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_kyc_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_mood_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mood_repository.dart';
import 'package:soothifyafrica/app/modules/user/checkin/checkin_screen.dart';
import 'package:soothifyafrica/app/modules/user/checkin/controller/checkin_controller.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/checkin_golden_test.dart
const _art = [
  'assets/images/mood/female_awful.png',
  'assets/images/mood/female_low.png',
  'assets/images/mood/female_good.png',
  'assets/images/mood/female_awesome.png',
  'assets/images/checkin/ic_more_vertical.png',
  'assets/images/checkin/ic_calendar_search.png',
];

/// August 2024, matching the month the frames print.
DateTime _now() => DateTime(2024, 8, 20, 12, 1);

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<CheckinController> mount(WidgetTester tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();

    final repo = LocalMoodRepository(now: () => DateTime(2024, 8, 2, 12, 1));
    await repo.record(0.1);   // an "Awful" day, as the frame marks the 2nd

    Get.put<MoodRepository>(repo);
    Get.put<KycRepository>(LocalKycRepository());
    final c = Get.put(CheckinController(
      repo,
      Get.find<KycRepository>(),
      CheckinKind.mood,
      now: _now,
    ));
    await pumpScreen(tester, const CheckinScreen());
    await tester.pumpAndSettle();
    return c;
  }

  testWidgets('the calendar draws a circle per day', (tester) async {
    final c = await mount(tester);
    await precacheAll(tester, find.byType(CheckinScreen), _art);

    expect(find.text('Mood Check-Ins'), findsOneWidget);
    expect(find.text('August 2024'), findsOneWidget);
    expect(find.text('July 2024'), findsOneWidget);
    // The frame has no confirm button on this screen; the earlier build
    // added one under every month.
    expect(find.text('Select date'), findsNothing);
    expect(c.showingEntry.value, isFalse);

    await expectLater(find.byType(CheckinScreen),
        matchesGoldenFile('goldens/checkin_calendar.png'));
  });

  testWidgets('picking a recorded day shows that entry', (tester) async {
    final c = await mount(tester);
    await precacheAll(tester, find.byType(CheckinScreen), _art);

    await c.selectDate(DateTime(2024, 8, 2));
    await tester.pumpAndSettle();

    expect(c.showingEntry.value, isTrue);
    // The date line and the level, not the frame's nine-mood emoji vocabulary.
    expect(find.textContaining('Friday, 2 Aug'), findsOneWidget);
    expect(find.text(MoodLevel.awful.label), findsOneWidget);
    expect(find.text('August 2024'), findsNothing);

    await expectLater(find.byType(CheckinScreen),
        matchesGoldenFile('goldens/checkin_entry.png'));
  });

  testWidgets('the calendar glyph returns from an entry', (tester) async {
    final c = await mount(tester);
    await c.selectDate(DateTime(2024, 8, 2));
    await tester.pumpAndSettle();

    c.backToCalendar();
    await tester.pumpAndSettle();

    expect(c.showingEntry.value, isFalse);
    expect(find.text('August 2024'), findsOneWidget);
  });

  testWidgets('a day with nothing recorded stays on the calendar',
      (tester) async {
    final c = await mount(tester);

    await c.selectDate(DateTime(2024, 8, 15));
    await tester.pumpAndSettle();

    expect(c.showingEntry.value, isFalse);
    expect(find.text('August 2024'), findsOneWidget);
  });
}
