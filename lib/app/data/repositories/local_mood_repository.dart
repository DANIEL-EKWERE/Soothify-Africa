import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/app_exception.dart';
import '../models/mood.dart';
import 'mood_repository.dart';

/// Stores check-ins on the device.
///
/// Deliberately the real store rather than a throwaway mock: mood history is
/// personal data that should survive offline anyway, so this stays useful as a
/// local cache once the API exists rather than being thrown away.
///
/// Backed by SharedPreferences for now because the dataset is small (one short
/// record per day). If history grows features — charts, ranges, sync state —
/// move it to drift; the interface will not change.
class LocalMoodRepository implements MoodRepository {
  LocalMoodRepository({DateTime Function()? now}) : _now = now ?? DateTime.now;

  static const _key = 'moodEntries';

  /// Overridable so "today" can be pinned in tests. [MoodRecordController]
  /// takes the same parameter — both must agree on what day it is, or a
  /// seeded "today" entry stops lining up with the day the screen highlights.
  final DateTime Function() _now;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<MoodEntry>> _readAll() async {
    try {
      final raw = (await _prefs).getStringList(_key) ?? const [];
      return raw
          .map((e) => MoodEntry.fromJson(
              jsonDecode(e) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupt or migrated data should not brick the screen.
      throw const CacheException();
    }
  }

  @override
  Future<List<MoodEntry>> history({int limit = 50}) async {
    final all = await _readAll()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return all.take(limit).toList();
  }

  @override
  Future<MoodEntry> record(double score, {String note = ''}) async {
    final all = await _readAll();
    final now = _now();

    // One entry per day: re-checking replaces today's rather than stacking.
    all.removeWhere((e) => _isSameDay(e.recordedAt, now));

    final entry = MoodEntry(
      id: now.microsecondsSinceEpoch.toString(),
      score: score,
      recordedAt: now,
      note: note,
    );
    all.add(entry);

    await (await _prefs).setStringList(
      _key,
      all.map((e) => jsonEncode(e.toJson())).toList(),
    );
    return entry;
  }

  @override
  Future<List<MoodEntry>> between(DateTime from, DateTime to) async {
    // Compare on day boundaries so a time-of-day difference never drops an
    // entry at the edge of the range.
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day)
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));

    final all = await _readAll();
    return all
        .where((e) =>
            !e.recordedAt.isBefore(start) && !e.recordedAt.isAfter(end))
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
  }

  @override
  Future<MoodEntry?> todaysEntry() async {
    final now = _now();
    for (final e in await _readAll()) {
      if (_isSameDay(e.recordedAt, now)) return e;
    }
    return null;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
