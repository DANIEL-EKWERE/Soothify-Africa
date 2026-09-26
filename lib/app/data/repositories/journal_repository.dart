import '../models/journal_entry.dart';

/// The contract the Journal screens code against.
abstract class JournalRepository {
  /// Newest first.
  Future<List<JournalEntry>> entries({int limit = 100});

  Future<JournalEntry?> getById(String id);

  /// Writes a new note, or replaces [id] when one is given.
  Future<JournalEntry> save({
    required String body,
    String title = '',
    String? id,
  });

  Future<void> delete(String id);
}
