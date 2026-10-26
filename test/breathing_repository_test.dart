import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/errors/app_exception.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/repositories/breathing_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_breathing_repository.dart';
import 'package:soothifyafrica/app/data/repositories/syncing_breathing_repository.dart';

/// Stands in for the server.
class _FakeRemote implements BreathingRepository {
  _FakeRemote({this.answer = const BreathingState(), this.fails = false});

  BreathingState answer;
  bool fails;
  int recorded = 0;
  int? lastSeconds;

  @override
  Future<BreathingState> state({DateTime? now}) async {
    if (fails) throw const NetworkException('offline');
    return answer;
  }

  @override
  Future<BreathingState> recordMinute({int seconds = 60, DateTime? now}) async {
    lastSeconds = seconds;
    if (fails) throw const NetworkException('offline');
    recorded += 1;
    return answer;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefUtils.resetForTesting();
    await PrefUtils().init();
  });

  group('local', () {
    test('a first minute is a one-day streak', () async {
      final repo = LocalBreathingRepository();
      expect((await repo.state()).streak, 0);
      expect((await repo.recordMinute()).streak, 1);
      expect((await repo.state()).streak, 1);
    });

    test('twice in one day is still one day', () async {
      final repo = LocalBreathingRepository();
      final day = DateTime(2026, 3, 4);
      await repo.recordMinute(now: day);
      expect((await repo.recordMinute(now: day)).streak, 1);
    });

    test('consecutive days add up, a gap starts again', () async {
      final repo = LocalBreathingRepository();
      await repo.recordMinute(now: DateTime(2026, 3, 4));
      expect((await repo.recordMinute(now: DateTime(2026, 3, 5))).streak, 2);
      // 6th missed.
      expect((await repo.recordMinute(now: DateTime(2026, 3, 7))).streak, 1);
    });
  });

  group('syncing', () {
    test('a guest keeps a streak on the device alone', () async {
      final remote = _FakeRemote();
      final repo = SyncingBreathingRepository(
        LocalBreathingRepository(),
        remote,
        signedIn: () => false,
      );

      expect((await repo.recordMinute()).streak, 1);
      expect(remote.recorded, 0, reason: 'nobody to send it to');
    });

    test('the account can raise what the device knows', () async {
      final remote = _FakeRemote(answer: const BreathingState(streak: 40));
      final repo = SyncingBreathingRepository(
        LocalBreathingRepository(),
        remote,
        signedIn: () => true,
      );

      // A fresh install: the device knows nothing, the account knows forty.
      expect((await repo.state()).streak, 40);
    });

    test('a shorter server answer never lowers the device', () async {
      final local = LocalBreathingRepository();
      await local.recordMinute(now: DateTime(2026, 3, 4));
      await local.recordMinute(now: DateTime(2026, 3, 5));
      final repo = SyncingBreathingRepository(
        local,
        _FakeRemote(answer: const BreathingState(streak: 1)),
        signedIn: () => true,
      );

      expect((await repo.state()).streak, 2);
    });

    test('a minute survives the server being unreachable', () async {
      final remote = _FakeRemote(fails: true);
      final repo = SyncingBreathingRepository(
        LocalBreathingRepository(),
        remote,
        signedIn: () => true,
      );

      expect((await repo.recordMinute()).streak, 1);
      expect((await repo.state()).streak, 1);
    });

    test('the whole minute is what gets reported', () async {
      final remote = _FakeRemote(answer: const BreathingState(streak: 1));
      final repo = SyncingBreathingRepository(
        LocalBreathingRepository(),
        remote,
        signedIn: () => true,
      );

      await repo.recordMinute(seconds: 60);
      expect(remote.lastSeconds, 60);
    });
  });
}
