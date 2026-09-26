/// One journal note.
///
/// Both states are designed: the empty one (`259:36946`) and the populated
/// list (`259:36965`), whose cards print a date, a heading and the note.
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.body,
    required this.createdAt,
    this.title = '',
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;

  /// Keys are snake_case to match what DRF will serve.
  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: '${json['id']}',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        createdAt: DateTime.tryParse('${json['created_at']}')?.toLocal() ??
            DateTime.now(),
      );

  /// The heading a card shows.
  ///
  /// The composer (`259:29454`) has no title field — only the prompt and the
  /// note — while the list card draws a heading above the body. So the
  /// heading is the note's own opening line, which is what someone writing
  /// under a prompt actually produces. Kept as a stored field rather than a
  /// getter, so a real title can be supplied later without a migration.
  static String titleFrom(String body) {
    final first = body
        .split('\n')
        .map((l) => l.trim())
        .firstWhere((l) => l.isNotEmpty, orElse: () => '');
    if (first.length <= _titleLimit) return first;
    // Cut on a word boundary rather than mid-word, when there is one to use.
    final cut = first.lastIndexOf(' ', _titleLimit);
    return '${first.substring(0, cut > 20 ? cut : _titleLimit).trimRight()}…';
  }

  static const int _titleLimit = 48;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}
