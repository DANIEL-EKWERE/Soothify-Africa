import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/errors/app_exception.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/journal_entry.dart';
import 'package:soothifyafrica/app/data/models/mood.dart';
import 'package:soothifyafrica/app/data/repositories/journal_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_journal_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_mood_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mood_repository.dart';
import 'package:soothifyafrica/app/data/repositories/syncing_journal_repository.dart';
import 'package:soothifyafrica/app/data/repositories/syncing_mood_repository.dart';

/// Mood and journal, on the device first and the server second.
///
/// The rule under test is the one that matters to somebody on a Lagos
/// commute: a check-in or a note is saved the moment it is made, whatever
/// the network is doing, and the server catches up afterwards.
void main() {
  setUp(() async {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    await PrefUtils().init();
  });

  group('mood check-ins', () {
    test('are saved even when the server cannot be reached', () async {
      final server = _OfflineMood();
      final repository =
          SyncingMoodRepository(LocalMoodRepository(), server);

      final saved = await repository.record(0.75, note: 'Lighter today');

      // The caller is answered from the device: the check-in is a fact the
      // moment it is made.
      expect(saved.score, 0.75);
      expect((await repository.history()).single.note, 'Lighter today');
    });

    test('reach the server when it is there', () async {
      final server = _RecordingMood();
      final repository =
          SyncingMoodRepository(LocalMoodRepository(), server);

      await repository.record(0.5);

      expect(server.recorded, [0.5]);
    });

    test('what was missed goes up with the next one that gets through',
        () async {
      final server = _RecordingMood()..offline = true;
      final repository =
          SyncingMoodRepository(LocalMoodRepository(), server);

      await repository.record(0.2, note: 'rough');
      expect(server.recorded, isEmpty);

      server.offline = false;
      await repository.record(0.8, note: 'better');

      // The one that got through, and then the one that had been waiting.
      expect(server.recorded, containsAll(<double>[0.8, 0.2]));
    });

    test('reads never wait on the network', () async {
      final repository =
          SyncingMoodRepository(LocalMoodRepository(), _OfflineMood());
      await repository.record(0.6);

      // Every one of these would throw if it asked the server.
      expect(await repository.history(), hasLength(1));
      expect(await repository.todaysEntry(), isNotNull);
      expect(
        await repository.between(
          DateTime.now().subtract(const Duration(days: 1)),
          DateTime.now(),
        ),
        hasLength(1),
      );
    });
  });

  group('journal notes', () {
    test('are kept even when the server cannot be reached', () async {
      final repository = SyncingJournalRepository(
        LocalJournalRepository(),
        _OfflineJournal(),
      );

      final saved = await repository.save(body: 'A difficult morning.');

      expect(saved.body, 'A difficult morning.');
      expect((await repository.entries()).single.body, 'A difficult morning.');
    });

    test('an edit updates the same row on the server, not a second copy',
        () async {
      final server = _RecordingJournal();
      final repository =
          SyncingJournalRepository(LocalJournalRepository(), server);

      final first = await repository.save(body: 'Draft');
      await repository.save(body: 'Finished', id: first.id);

      expect(server.saved, ['Draft', 'Finished']);
      // The second save carried the id the server gave the first, so the
      // note was updated rather than written twice.
      expect(server.updatedIds, ['server-1']);
    });

    test('a note written offline is sent with the next one', () async {
      final server = _RecordingJournal()..offline = true;
      final repository =
          SyncingJournalRepository(LocalJournalRepository(), server);

      await repository.save(body: 'On the train');
      expect(server.saved, isEmpty);

      server.offline = false;
      await repository.save(body: 'At home');

      expect(server.saved, containsAll(<String>['At home', 'On the train']));
    });

    test('deleting removes it here even if the server never hears', () async {
      final server = _RecordingJournal();
      final repository =
          SyncingJournalRepository(LocalJournalRepository(), server);
      final note = await repository.save(body: 'Delete me');

      server.offline = true;
      await repository.delete(note.id);

      // What must not happen is the note reappearing on the screen.
      expect(await repository.entries(), isEmpty);
    });
  });
}

/// A server that is never reachable.
class _OfflineMood implements MoodRepository {
  @override
  Future<List<MoodEntry>> history({int limit = 50}) =>
      throw const NetworkException();

  @override
  Future<List<MoodEntry>> between(DateTime from, DateTime to) =>
      throw const NetworkException();

  @override
  Future<MoodEntry?> todaysEntry() => throw const NetworkException();

  @override
  Future<MoodEntry> record(double score, {String note = ''}) =>
      throw const NetworkException();
}

/// A server that remembers what it was told, and can be taken offline.
class _RecordingMood implements MoodRepository {
  bool offline = false;
  final List<double> recorded = [];

  @override
  Future<MoodEntry> record(double score, {String note = ''}) async {
    if (offline) throw const NetworkException();
    recorded.add(score);
    return MoodEntry(
      id: 'server-${recorded.length}',
      score: score,
      note: note,
      recordedAt: DateTime.now(),
    );
  }

  @override
  Future<List<MoodEntry>> history({int limit = 50}) async => const [];

  @override
  Future<List<MoodEntry>> between(DateTime from, DateTime to) async => const [];

  @override
  Future<MoodEntry?> todaysEntry() async => null;
}

class _OfflineJournal implements JournalRepository {
  @override
  Future<List<JournalEntry>> entries({int limit = 100}) =>
      throw const NetworkException();

  @override
  Future<JournalEntry?> getById(String id) => throw const NetworkException();

  @override
  Future<JournalEntry> save({
    required String body,
    String title = '',
    String? id,
  }) =>
      throw const NetworkException();

  @override
  Future<void> delete(String id) => throw const NetworkException();
}

class _RecordingJournal implements JournalRepository {
  bool offline = false;
  final List<String> saved = [];
  final List<String> updatedIds = [];

  @override
  Future<JournalEntry> save({
    required String body,
    String title = '',
    String? id,
  }) async {
    if (offline) throw const NetworkException();
    saved.add(body);
    if (id != null) updatedIds.add(id);
    return JournalEntry(
      id: id ?? 'server-${saved.length}',
      title: title,
      body: body,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<JournalEntry>> entries({int limit = 100}) async => const [];

  @override
  Future<JournalEntry?> getById(String id) async => null;

  @override
  Future<void> delete(String id) async {
    if (offline) throw const NetworkException();
  }
}
