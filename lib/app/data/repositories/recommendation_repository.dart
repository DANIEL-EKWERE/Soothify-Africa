import '../models/expert_recommendation.dart';

/// What practitioners have pointed this client at — the Journal's second
/// tab, and the screen behind one card.
///
/// Separate from [JournalRepository] on purpose: a journal entry is the
/// client's own writing and is kept on the device first, while a
/// recommendation is written by somebody else and only ever arrives from
/// the server. There is nothing to sync and nothing to keep offline.
abstract class RecommendationRepository {
  /// Newest first, as `/api/v1/recommendations/` returns them.
  Future<List<ExpertRecommendation>> mine();

  /// Opening one clears its "New" pill and the count on the tab. Returns
  /// the row as the server now has it.
  Future<ExpertRecommendation> markRead(String id);
}
