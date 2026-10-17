import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/journal_entry.dart';
import 'journal_repository.dart';

/// Journal notes against `/api/v1/wellbeing/journal/`.
///
/// Rarely used on its own — see [SyncingJournalRepository], which keeps the
/// device's copy authoritative so a note written on a train is not lost.
class ApiJournalRepository implements JournalRepository {
  ApiJournalRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<JournalEntry>> entries({int limit = 100}) async {
    final rows = await _api.getList('/wellbeing/journal/?limit=$limit');
    return rows.map(JournalEntry.fromJson).toList();
  }

  @override
  Future<JournalEntry?> getById(String id) async {
    try {
      return JournalEntry.fromJson(await _api.get('/wellbeing/journal/$id/'));
    } on NotFoundException {
      return null;
    }
  }

  @override
  Future<JournalEntry> save({
    required String body,
    String title = '',
    String? id,
  }) async {
    final payload = {'body': body, 'title': title};
    final answer = id == null || id.isEmpty
        ? await _api.post('/wellbeing/journal/', body: payload)
        : await _api.put('/wellbeing/journal/$id/', body: payload);
    return JournalEntry.fromJson(answer);
  }

  @override
  Future<void> delete(String id) async {
    await _api.delete('/wellbeing/journal/$id/');
  }
}
