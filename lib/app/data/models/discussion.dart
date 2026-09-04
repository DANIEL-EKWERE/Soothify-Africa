/// A thread on the community forum — Figma "Join discussion" (135:5035).
class Discussion {
  const Discussion({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    required this.postedAt,
  });

  final String id;
  final String title;
  final String body;

  /// The poster's forum handle, not their account name.
  final String author;

  final int likes;
  final int comments;
  final int shares;
  final DateTime postedAt;

  /// The design prints "1 hour ago". Kept coarse deliberately: a precise
  /// timestamp on a mental-health post is more identifying than it is useful.
  String relativeTime(DateTime now) {
    final d = now.difference(postedAt);
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) {
      return '${d.inHours} hour${d.inHours == 1 ? '' : 's'} ago';
    }
    return '${d.inDays} day${d.inDays == 1 ? '' : 's'} ago';
  }

  factory Discussion.fromJson(Map<String, dynamic> json) => Discussion(
        id: '${json['id']}',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        author: json['author_username'] as String? ?? '',
        likes: json['like_count'] as int? ?? 0,
        comments: json['comment_count'] as int? ?? 0,
        shares: json['share_count'] as int? ?? 0,
        postedAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now(),
      );
}
