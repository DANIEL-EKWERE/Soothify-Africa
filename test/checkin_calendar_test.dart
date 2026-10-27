import 'package:flutter/material.dart';
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

/// The faces on the check-in calendar.
///
/// They did not appear until the calendar was tapped. The Obx around it read
/// only `months` and `selected`; the moods were read inside `markBuilder`,
/// which runs during the calendar's own build -- a child build, outside the
/// Obx closure -- so arriving history registered no dependency and nothing
/// repainted. Tapping changed `selected`, which the closure did read, and
/// the faces appeared then.
/// A repository that answers after a delay, like a real one over a network.
///
/// Without this the history is already there when the first frame is drawn,
/// and the bug cannot happen: it is entirely about what does and does not
/// repaint when the answer lands *after* the screen is up.
class _SlowMoodRepository implements MoodRepository {
  _SlowMoodRepository(this._entries, {this.delay = const Duration(seconds: 1)});

  final List<MoodEntry> _entries;
  final Duration delay;

  @override
  Future<List<MoodEntry>> history({int limit = 50}) async {
    await Future<void>.delayed(delay);
    return _entries;
  }

  @override
  Future<List<MoodEntry>> between(DateTime from, DateTime to) async =>
      history();

  @override
  Future<MoodEntry?> todaysEntry() async => null;

  @override
  Future<MoodEntry> record(double score, {String note = ''}) async =>
      throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  DateTime now() => DateTime(2024, 8, 20, 12);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefUtils.resetForTesting();
    await PrefUtils().init();
  });

  tearDown(Get.reset);

  testWidgets('a face appears when the history lands, with no tap',
      (tester) async {
    useDesignFrame(tester);

    final moods = _SlowMoodRepository([
      MoodEntry(
        id: '1',
        score: MoodLevel.awful.representativeScore,
        recordedAt: DateTime(2024, 8, 2, 12),
      ),
    ]);

    Get.put<MoodRepository>(moods);
    Get.put<KycRepository>(LocalKycRepository());
    Get.put(CheckinController(
      moods,
      Get.find<KycRepository>(),
      CheckinKind.mood,
      now: now,
    ));

    // The screen is up before the answer arrives.
    await pumpScreen(tester, const CheckinScreen());
    expect(faces, findsNothing, reason: 'nothing is loaded yet');

    // The answer lands. Nothing is tapped.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(
      faces,
      findsWidgets,
      reason: 'the history arrived and no face was drawn',
    );
  });

  testWidgets('a calendar with nothing recorded draws no faces',
      (tester) async {
    useDesignFrame(tester);

    Get.put<MoodRepository>(LocalMoodRepository(now: now));
    Get.put<KycRepository>(LocalKycRepository());
    Get.put(CheckinController(
      Get.find<MoodRepository>(),
      Get.find<KycRepository>(),
      CheckinKind.mood,
      now: now,
    ));

    await pumpScreen(tester, const CheckinScreen());
    await tester.pumpAndSettle();

    expect(faces, findsNothing);
  });
}

/// The character illustration drawn on a day that has an entry.
final faces = find.byWidgetPredicate(
  (w) =>
      w is Image &&
      w.image is AssetImage &&
      (w.image as AssetImage).assetName.contains('assets/images/mood/'),
);
