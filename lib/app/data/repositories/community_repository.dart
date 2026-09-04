import '../models/comment.dart';
import '../models/discussion.dart';

/// The contract the community screens code against.
abstract class CommunityRepository {
  Future<List<Discussion>> getDiscussions({int page = 1});

  /// Returns the created thread so the caller can show it without refetching.
  Future<Discussion> post({required String body, required String author});

  Future<List<Comment>> getComments(String discussionId);

  Future<Comment> comment({
    required String discussionId,
    required String body,
    required String author,
  });
}
