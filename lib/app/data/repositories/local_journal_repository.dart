import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/app_exception.dart';
import '../models/journal_entry.dart';
import 'journal_repository.dart';

/// Keeps journal entries on the device.
///
/// The real store rather than a mock, for the same reason mood check-ins are:
/// what someone writes about their own state is theirs, it should survive
/// being offline, and it should not vanish when the app is closed — which is
/// what "saving is not built yet" meant until now.
///
/// SharedPreferences suits the shape of the data (a handful of short notes).
/// If entries grow attachments or need full-text search, move to drift; the
/// interface does not change.
class LocalJournalRepository implements JournalRepository {
  LocalJournalRepository({DateTime Function()? now}) : _now = now ?? DateTime.now;

  static const _key = 'journalEntries';

  /// Overridable so a test can pin the date a note is written on, which the
  /// list prints.
  final DateTime Function() _now;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  final _random = Random();

  /// A timestamp alone is not unique enough to be an id here.
  ///
  /// The clock is injectable, so in a test two notes share a microsecond and
  /// the second silently replaces the first — and even on a real clock, two
  /// writes inside one microsecond would. The timestamp keeps ids roughly
  /// ordered; the suffix is what makes them distinct.
  String _newId() =>
      '${_now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';

  Future<List<JournalEntry>> _readAll() async {
    try {
      final raw = (await _prefs).getStringList(_key) ?? const [];
      return raw
          .map((e) =>
              JournalEntry.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupt or migrated data should not brick the screen.
      throw const CacheException();
    }
  }

  Future<void> _writeAll(List<JournalEntry> all) async => (await _prefs)
      .setStringList(_key, all.map((e) => jsonEncode(e.toJson())).toList());

  @override
  Future<List<JournalEntry>> entries({int limit = 100}) async {
    final all = await _readAll()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all.take(limit).toList();
  }

  @override
  Future<JournalEntry?> getById(String id) async {
    for (final e in await _readAll()) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<JournalEntry> save({
    required String body,
    String title = '',
    String? id,
  }) async {
    final all = await _readAll();
    final existing = id == null
        ? null
        : all.cast<JournalEntry?>().firstWhere((e) => e?.id == id,
            orElse: () => null);

    final entry = JournalEntry(
      id: id ?? _newId(),
      title: title.isNotEmpty ? title : JournalEntry.titleFrom(body),
      body: body,
      // Editing keeps the day it was written, so the list does not reshuffle
      // because a typo was fixed.
      createdAt: existing?.createdAt ?? _now(),
    );

    all
      ..removeWhere((e) => e.id == entry.id)
      ..add(entry);
    await _writeAll(all);
    return entry;
  }

  @override
  Future<void> delete(String id) async {
    final all = await _readAll()..removeWhere((e) => e.id == id);
    await _writeAll(all);
  }
}
