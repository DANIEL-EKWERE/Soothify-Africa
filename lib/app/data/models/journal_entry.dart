/// One journal note.
///
/// The designed screen is the empty state (Figma `135:2091`); a populated
/// variant exists at `135:2105`. This models what a note needs so the list can
/// be built when that frame is read.
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}
