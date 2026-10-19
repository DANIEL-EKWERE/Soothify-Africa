import '../models/expert_recommendation.dart';
import 'recommendation_repository.dart';

/// The frame's own three rows, for the build that runs without a server.
class MockRecommendationRepository implements RecommendationRepository {
  MockRecommendationRepository({DateTime Function()? now})
      : _rows = ExpertRecommendation.sample(now: now);

  List<ExpertRecommendation> _rows;

  @override
  Future<List<ExpertRecommendation>> mine() async => _rows;

  @override
  Future<ExpertRecommendation> markRead(String id) async {
    _rows = [
      for (final row in _rows) row.id == id ? row.markedRead() : row,
    ];
    return _rows.firstWhere((row) => row.id == id);
  }
}
