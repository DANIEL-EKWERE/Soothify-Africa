/// A reply on a discussion thread — Figma 135:6190.
class Comment {
  const Comment({
    required this.id,
    required this.author,
    required this.body,
    required this.postedAt,
  });

  final String id;

  /// The commenter's forum handle, as with [Discussion.author].
  final String author;

  final String body;
  final DateTime postedAt;

  /// The design prints "20minute ago", "1 day ago", "1 Week ago" — coarse and
  /// inconsistently spaced. Normalised here; kept coarse for the same reason
  /// as [Discussion.relativeTime].
  String relativeTime(DateTime now) {
    final d = now.difference(postedAt);
    if (d.inMinutes < 60) return '${d.inMinutes} minutes ago';
    if (d.inHours < 24) {
      return '${d.inHours} hour${d.inHours == 1 ? '' : 's'} ago';
    }
    if (d.inDays < 7) {
      return '${d.inDays} day${d.inDays == 1 ? '' : 's'} ago';
    }
    final weeks = d.inDays ~/ 7;
    return '$weeks week${weeks == 1 ? '' : 's'} ago';
  }

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: '${json['id']}',
        author: json['author_username'] as String? ?? '',
        body: json['body'] as String? ?? '',
        postedAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now(),
      );
}
