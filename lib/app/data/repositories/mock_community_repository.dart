import '../models/comment.dart';
import '../models/discussion.dart';
import 'community_repository.dart';

/// Local stand-in for the forum API.
///
/// Posts are held in memory only — deliberately not persisted. A draft that
/// survives a restart would look like it reached a community that cannot see
/// it, which is worse than losing it.
class MockCommunityRepository implements CommunityRepository {
  MockCommunityRepository({DateTime Function()? now})
      : _now = now ?? DateTime.now;

  static const _latency = Duration(milliseconds: 400);

  /// Overridable so "1 hour ago" can be pinned in a golden.
  final DateTime Function() _now;

  final List<Discussion> _posted = [];
  final Map<String, List<Comment>> _comments = {};

  static const _body =
      'Depression is a topic people don’t talk\nabout enough, I was battling '
      'with \ndepression for a while and I found help here.';

  List<Discussion> _seed() {
    final now = _now();
    return [
      Discussion(
        id: '1',
        title: 'Depressed and tired',
        body: _body,
        author: 'Kosin',
        likes: 3,
        comments: 4,
        shares: 3,
        postedAt: now.subtract(const Duration(hours: 1)),
      ),
      Discussion(
        id: '2',
        title: 'My job is stressful',
        body: _body,
        author: 'Paul',
        likes: 3,
        comments: 4,
        shares: 3,
        postedAt: now.subtract(const Duration(hours: 1)),
      ),
      Discussion(
        id: '3',
        title: 'My job is stressful',
        body: _body,
        author: 'Chizzy',
        likes: 3,
        comments: 4,
        shares: 3,
        postedAt: now.subtract(const Duration(hours: 1)),
      ),
      Discussion(
        id: '4',
        title: 'My job is stressful',
        body: _body,
        author: 'Fatima',
        likes: 3,
        comments: 4,
        shares: 3,
        postedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }

  @override
  Future<List<Discussion>> getDiscussions({int page = 1}) async {
    await Future<void>.delayed(_latency);
    // Newest first, so a post made in this session leads the list.
    return [..._posted.reversed, ..._seed()];
  }

  /// The three replies the thread frame shows.
  List<Comment> _seedComments() {
    final now = _now();
    return [
      Comment(
        id: 'c1',
        author: 'Chidera',
        body: 'I think people should be open to having conversations like '
            'this, it will help them get better help.',
        postedAt: now.subtract(const Duration(minutes: 20)),
      ),
      Comment(
        id: 'c2',
        author: 'Fatima',
        body: 'Having sleep disorder, lack of interest in activities you find '
            'amazing can be a sign to get help.',
        postedAt: now.subtract(const Duration(days: 1)),
      ),
      Comment(
        id: 'c3',
        author: 'John',
        body: 'Having sleep disorder, lack of interest in activities you find '
            'amazing can be a sign to get help.',
        postedAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }

  @override
  Future<List<Comment>> getComments(String discussionId) async {
    await Future<void>.delayed(_latency);
    return [..._seedComments(), ...?_comments[discussionId]];
  }

  @override
  Future<Comment> comment({
    required String discussionId,
    required String body,
    required String author,
  }) async {
    await Future<void>.delayed(_latency);
    final now = _now();
    final created = Comment(
      id: 'local-${now.microsecondsSinceEpoch}',
      author: author,
      body: body.trim(),
      postedAt: now,
    );
    _comments.putIfAbsent(discussionId, () => []).add(created);
    return created;
  }

  @override
  Future<Discussion> post({
    required String body,
    required String author,
  }) async {
    await Future<void>.delayed(_latency);
    final now = _now();
    final discussion = Discussion(
      id: 'local-${now.microsecondsSinceEpoch}',
      // The design's compose screen captures one body field and no title, so
      // the first line stands in as the heading.
      title: body.trim().split('\n').first,
      body: body.trim(),
      author: author,
      postedAt: now,
    );
    _posted.add(discussion);
    return discussion;
  }
}
