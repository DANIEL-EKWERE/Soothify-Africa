import '../../core/errors/app_exception.dart';
import '../../core/utils/logger.dart';
import '../models/journal_entry.dart';
import 'journal_repository.dart';

/// Journal notes, on the device and on the server.
///
/// Same bargain as [SyncingMoodRepository]: the device answers every read
/// and every write lands there first, because a journal that needs a network
/// to accept a note is a journal that loses notes. The server is told after,
/// and told again later if it could not be reached.
///
/// The ids are the device's. A note sent to the server comes back with an id
/// of its own, which is kept alongside so an edit updates the same row
/// rather than adding a second copy of a note the person only wrote once.
class SyncingJournalRepository implements JournalRepository {
  SyncingJournalRepository(this._local, this._remote);

  final JournalRepository _local;
  final JournalRepository _remote;

  /// Local id to the server's id, for notes the server has.
  final Map<String, String> _serverIds = <String, String>{};

  /// Local ids of notes the server has not accepted yet.
  final Set<String> _unsent = <String>{};

  @override
  Future<List<JournalEntry>> entries({int limit = 100}) =>
      _local.entries(limit: limit);

  @override
  Future<JournalEntry?> getById(String id) => _local.getById(id);

  @override
  Future<JournalEntry> save({
    required String body,
    String title = '',
    String? id,
  }) async {
    final saved = await _local.save(body: body, title: title, id: id);

    try {
      final sent = await _remote.save(
        body: body,
        title: title,
        // An edit of a note the server already holds updates that row.
        id: _serverIds[saved.id],
      );
      _serverIds[saved.id] = sent.id;
      _unsent.remove(saved.id);
      await _catchUp();
    } on AppException catch (error) {
      _unsent.add(saved.id);
      Log.e('journal note not sent yet', error: error);
    }
    return saved;
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);

    final remoteId = _serverIds.remove(id);
    _unsent.remove(id);
    if (remoteId == null) return;

    try {
      await _remote.delete(remoteId);
    } on AppException catch (error) {
      // The note is gone from the device, which is what the person asked
      // for. It will go from the server on the next delete that gets
      // through, or be cleaned up there -- what must not happen is the note
      // reappearing on this screen.
      Log.e('journal note deleted locally but not on the server', error: error);
    }
  }

  /// Sends the notes earlier attempts could not. Only after one that worked.
  Future<void> _catchUp() async {
    if (_unsent.isEmpty) return;
    for (final localId in Set.of(_unsent)) {
      final note = await _local.getById(localId);
      if (note == null) {
        _unsent.remove(localId);
        continue;
      }
      try {
        final sent = await _remote.save(
          body: note.body,
          title: note.title,
          id: _serverIds[localId],
        );
        _serverIds[localId] = sent.id;
        _unsent.remove(localId);
      } on AppException {
        return;     // still unreachable; the rest wait
      }
    }
  }
}
