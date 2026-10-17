import '../../core/network/api_client.dart';
import 'kyc_repository.dart';

/// The onboarding questionnaire, from `/api/v1/auth/kyc/`.
///
/// Answers are {question id: chosen option values} on both sides. The server
/// merges a PATCH into what it already holds, which is what lets the screen
/// save after each question without the next one wiping the last.
class ApiKycRepository implements KycRepository {
  ApiKycRepository(this._api);

  final ApiClient _api;

  @override
  Future<Map<String, Set<String>>> savedAnswers() async {
    final body = await _api.get('/auth/kyc/');
    final answers = body['answers'];
    if (answers is! Map) return {};

    return answers.map((question, chosen) {
      final values = chosen is List
          ? chosen.map((v) => '$v').toSet()
          : <String>{'$chosen'};
      return MapEntry('$question', values);
    });
  }

  @override
  Future<void> saveAnswers(Map<String, Set<String>> answers) async {
    await _api.patch(
      '/auth/kyc/',
      body: {
        'answers': answers.map(
          (question, chosen) => MapEntry(question, chosen.toList()),
        ),
      },
    );
  }

  @override
  Future<bool> isComplete() async {
    final body = await _api.get('/auth/kyc/');
    return body['is_complete'] == true;
  }

  @override
  Future<void> markComplete() async {
    await _api.post('/auth/kyc/complete/');
  }
}
