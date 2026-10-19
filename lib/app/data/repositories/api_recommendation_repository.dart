import '../../core/network/api_client.dart';
import '../models/expert_recommendation.dart';
import 'recommendation_repository.dart';

/// Recommendations, from `/api/v1/recommendations/`.
///
/// Each row carries the whole piece of content the expert chose, not its
/// id, so a list of ten cards is one request rather than eleven.
class ApiRecommendationRepository implements RecommendationRepository {
  ApiRecommendationRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<ExpertRecommendation>> mine() async {
    final rows = await _api.getList('/recommendations/');
    return rows.map(ExpertRecommendation.fromJson).toList();
  }

  @override
  Future<ExpertRecommendation> markRead(String id) async {
    final body = await _api.post('/recommendations/$id/read/');
    return ExpertRecommendation.fromJson(body);
  }
}
